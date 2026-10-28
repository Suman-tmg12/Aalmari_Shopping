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
        return uploadToBucket(file, profileBucket, "profile/" + userId + "/");
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
        if (key == null || key.isEmpty()) return null;

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
    }

    private String getExtension(String filename) {
        return null;
    }

    public void deleteFile(String path) {
    }
}