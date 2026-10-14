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

    @Value("${aws.s3.bucket}")
    private String bucket; // sellerimages123 — existing seller docs bucket

    @Value("${aws.s3.profileBucket}")
    private String profileBucket; // aalmari-profile-pic

    public S3Service(S3Client s3Client, S3Presigner s3Presigner) {
        this.s3Client = s3Client;
        this.s3Presigner = s3Presigner;
    }

    /**
     * Existing method — uploads seller-related files to the seller bucket.
     * Returns the S3 key (path) to store in MySQL — NOT the file itself.
     */
    public String upload(MultipartFile file, Long userId, String folder) {
        return uploadToBucket(file, bucket, "sellers/" + userId + "/" + folder + "/");
    }

    /**
     * Uploads a user's profile picture to the dedicated aalmari-profile-pic bucket.
     * Key pattern: profile/{userId}/{uuid}.ext
     * Returns the S3 key (path) to store in MySQL — NOT the file itself.
     */
    public String uploadProfilePic(MultipartFile file, Long userId) {
        return uploadToBucket(file, profileBucket, "profile/" + userId + "/");
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

    /**
     * Generates a temporary pre-signed URL so the browser can display a
     * private S3 object (profile picture) without making the bucket public.
     * Expires in 30 minutes — safe to call fresh on every page load.
     */
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
        if (filename == null || !filename.contains(".")) return "";
        return filename.substring(filename.lastIndexOf('.'));
    }
}