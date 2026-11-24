package com.example.aalmari.service.impl;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest;
import software.amazon.awssdk.services.s3.presigner.model.PresignedGetObjectRequest;

import javax.imageio.ImageIO;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.Duration;
import java.util.UUID;

@Service
public class S3Service {

    private final S3Client s3Client;
    private final S3Presigner s3Presigner;

    @Value("${aws.accessKeyId}")
    private String accessKey;

    @Value("${aws.secretKey}")
    private String secretKey;

    @Value("${aws.region}")
    private String region;

    @Value("${aws.s3.bucket}")
    private String bucket; // e.g., sellerimages123

    @Value("${aws.s3.profileBucket}")
    private String profileBucket; // e.g., aalmari-profile-pic

    @Value("${aws.s3.productImages}")
    private String productImagesBucket; // e.g., aalmari-product-images

    public S3Service(S3Client s3Client, S3Presigner s3Presigner) {
        this.s3Client = s3Client;
        this.s3Presigner = s3Presigner;
    }

    public String upload(MultipartFile file, Long userId, String folder) {
        return uploadToBucket(file, bucket, "sellers/" + userId + "/" + folder + "/");
    }

    public String uploadProfilePic(MultipartFile file, Long userId) {
        if (file == null || file.isEmpty()) return null;
        if (file.getSize() > 2 * 1024 * 1024) {
            throw new IllegalArgumentException("Profile photo must be smaller than 2MB");
        }

        String contentType = file.getContentType();
        if (contentType == null || !(contentType.equals("image/jpeg")
                || contentType.equals("image/png")
                || contentType.equals("image/webp")
                || contentType.equals("image/gif"))) {
            throw new IllegalArgumentException("Profile photo must be JPG, PNG, GIF or WebP");
        }

        try {
            BufferedImage source = ImageIO.read(file.getInputStream());
            if (source == null) throw new IllegalArgumentException("Invalid profile image");

            BufferedImage square = cropAndResize(source, 512);
            ByteArrayOutputStream output = new ByteArrayOutputStream();
            if (!ImageIO.write(square, "jpg", output)) {
                throw new IllegalArgumentException("Unable to process profile image");
            }

            byte[] bytes = output.toByteArray();
            String key = "profile/" + userId + "/" + UUID.randomUUID() + ".jpg";
            s3Client.putObject(
                    PutObjectRequest.builder()
                            .bucket(profileBucket)
                            .key(key)
                            .contentType("image/jpeg")
                            .cacheControl("public, max-age=86400")
                            .build(),
                    RequestBody.fromBytes(bytes)
            );
            return key;
        } catch (IOException e) {
            throw new RuntimeException("Failed to process profile image", e);
        }
    }

    private BufferedImage cropAndResize(BufferedImage source, int size) {
        int width = source.getWidth();
        int height = source.getHeight();
        int cropSize = Math.min(width, height);
        int x = (width - cropSize) / 2;
        int y = (height - cropSize) / 2;

        BufferedImage cropped = new BufferedImage(cropSize, cropSize, BufferedImage.TYPE_INT_RGB);
        Graphics2D cropGraphics = cropped.createGraphics();
        cropGraphics.setColor(java.awt.Color.WHITE);
        cropGraphics.fillRect(0, 0, cropSize, cropSize);
        cropGraphics.drawImage(source, 0, 0, cropSize, cropSize, x, y, x + cropSize, y + cropSize, null);
        cropGraphics.dispose();

        BufferedImage resized = new BufferedImage(size, size, BufferedImage.TYPE_INT_RGB);
        Graphics2D graphics = resized.createGraphics();
        graphics.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
        graphics.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        graphics.setColor(java.awt.Color.WHITE);
        graphics.fillRect(0, 0, size, size);
        graphics.drawImage(cropped, 0, 0, size, size, null);
        graphics.dispose();
        return resized;
    }

    /**
     * FIXED: Uploads product images to the CORRECT bucket, organizes by sellerId, and returns a PUBLIC URL.
     */
    public String uploadProductImage(MultipartFile file, String folderPrefix, Long sellerId) {
        if (file == null || file.isEmpty()) {
            return null;
        }

        String ext = getExtension(file.getOriginalFilename());
        String safePrefix = folderPrefix.replace("/", "-").replace(" ", "-") + "-";

        // 👇 Organizes files in S3 as: products/5/info-jeans-uuid.jpg
        String key = "products/" + sellerId + "/" + safePrefix + UUID.randomUUID() + ext;

        try {
            s3Client.putObject(
                    PutObjectRequest.builder()
                            .bucket(productImagesBucket)
                            .key(key)
                            .contentType(file.getContentType())
                            .build(),
                    RequestBody.fromInputStream(file.getInputStream(), file.getSize())
            );

            return String.format("https://%s.s3.%s.amazonaws.com/%s",
                    productImagesBucket,
                    region,
                    key);

        } catch (IOException e) {
            throw new RuntimeException("Failed to upload product image to S3: " + file.getOriginalFilename(), e);
        }
    }

    private String uploadToBucket(MultipartFile file, String targetBucket, String prefix) {
        if (file == null || file.isEmpty()) return null;

        String ext = getExtension(file.getOriginalFilename());
        String key = prefix + UUID.randomUUID() + ext;

        try {
            s3Client.putObject(
                    PutObjectRequest.builder()
                            .bucket(targetBucket)
                            .key(key)
                            .contentType(file.getContentType())
                            .build(),
                    RequestBody.fromInputStream(file.getInputStream(), file.getSize())
            );
        } catch (IOException e) {
            throw new RuntimeException("Failed to upload file to S3: " + file.getOriginalFilename(), e);
        }
        return key;
    }

    public String generateProfilePicUrl(String key) {
        if (key == null || key.isBlank() || key.toLowerCase(java.util.Locale.ROOT).endsWith("null")
                || key.contains("../") || key.contains("\\\\")) return null;

        try {
            GetObjectRequest getObjectRequest = GetObjectRequest.builder()
                    .bucket(profileBucket)
                    .key(key)
                    .build();

            GetObjectPresignRequest presignRequest = GetObjectPresignRequest.builder()
                    .signatureDuration(Duration.ofMinutes(30))
                    .getObjectRequest(getObjectRequest)
                    .build();

            PresignedGetObjectRequest presignedRequest = s3Presigner.presignGetObject(presignRequest);
            return presignedRequest.url().toString();
        } catch (Exception e) {
            return String.format("https://%s.s3.%s.amazonaws.com/%s",
                    profileBucket, region, key);
        }
    }

    private String getExtension(String filename) {
        if (filename == null) return "";
        int dot = filename.lastIndexOf('.');
        if (dot < 0 || dot == filename.length() - 1) return "";
        String extension = filename.substring(dot).toLowerCase(java.util.Locale.ROOT);
        return extension.matches("\\.[a-z0-9]{1,10}") ? extension : "";
    }

    public void deleteFile(String path) {
        if (path == null || path.isBlank()) return;
        if (path.startsWith("http://") || path.startsWith("https://")) {
            return;
        }
        s3Client.deleteObject(builder -> builder.bucket(bucket).key(path));
    }

    public void deleteProfilePic(String path) {
        if (path == null || path.isBlank() || path.startsWith("http://") || path.startsWith("https://")
                || path.contains("../") || path.contains("\\\\")) return;
        s3Client.deleteObject(builder -> builder.bucket(profileBucket).key(path));
    }
}