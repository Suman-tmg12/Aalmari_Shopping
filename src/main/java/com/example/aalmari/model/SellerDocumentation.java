package com.example.aalmari.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "seller_documentation")
public class SellerDocumentation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "user_id", nullable = false, unique = true)
    private Long userId;

    // --- Store Information ---
    @Column(name = "store_name", nullable = false, length = 60)
    private String storeName;

    @Column(name = "store_tagline", length = 120)
    private String storeTagline;

    @Column(name = "primary_category", nullable = false)
    private String primaryCategory;

    @Column(name = "store_logo_path", nullable = false)
    private String storeLogoPath;

    @Column(name = "store_banner_path")
    private String storeBannerPath;

    // --- Business & Contact Info ---
    @Column(name = "business_email", nullable = false, length = 254)
    private String businessEmail;

    @Column(name = "phone_number", nullable = false, length = 20)
    private String phoneNumber;

    @Column(name = "business_registration_number", nullable = false, length = 200)
    private String businessRegistrationNumber;

    @Column(name = "tax_id", length = 50)
    private String taxId;

    // --- Verification Documents ---
    @Column(name = "doc_gov_id_path", nullable = false)
    private String docGovIdPath;

    @Column(name = "doc_biz_cert_path", nullable = false)
    private String docBizCertPath;

    @Column(name = "doc_address_proof_path", nullable = false)
    private String docAddressProofPath;

    // --- Bank Account Info ---
    @Column(name = "account_holder", nullable = false, length = 60)
    private String accountHolder;

    @Column(name = "bank_name", nullable = false, length = 60)
    private String bankName;

    @Column(name = "account_iban", nullable = false, length = 34)
    private String accountIban;

    // --- Status & Audit Info ---
    @Column(name = "agree_terms", nullable = false)
    private boolean agreeTerms;

    @Column(name = "status", nullable = false)
    private String status = "pending";

    @Column(name = "rejection_reason")
    private String rejectionReason;

    @Column(name = "reviewed_by")
    private Long reviewedBy;

    @Column(name = "reviewed_at")
    private LocalDateTime reviewedAt;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private LocalDateTime updatedAt;

    // Required by JPA
    public SellerDocumentation() {}

    // ---------- Getters & Setters ----------

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getStoreName() {
        return storeName;
    }

    public void setStoreName(String storeName) {
        this.storeName = storeName;
    }

    public String getStoreTagline() {
        return storeTagline;
    }

    public void setStoreTagline(String storeTagline) {
        this.storeTagline = storeTagline;
    }

    public String getPrimaryCategory() {
        return primaryCategory;
    }

    public void setPrimaryCategory(String primaryCategory) {
        this.primaryCategory = primaryCategory;
    }

    public String getStoreLogoPath() {
        return storeLogoPath;
    }

    public void setStoreLogoPath(String storeLogoPath) {
        this.storeLogoPath = storeLogoPath;
    }

    public String getStoreBannerPath() {
        return storeBannerPath;
    }

    public void setStoreBannerPath(String storeBannerPath) {
        this.storeBannerPath = storeBannerPath;
    }

    public String getBusinessEmail() {
        return businessEmail;
    }

    public void setBusinessEmail(String businessEmail) {
        this.businessEmail = businessEmail;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getBusinessRegistrationNumber() {
        return businessRegistrationNumber;
    }

    public void setBusinessRegistrationNumber(String businessRegistrationNumber) {
        this.businessRegistrationNumber = businessRegistrationNumber;
    }

    public String getTaxId() {
        return taxId;
    }

    public void setTaxId(String taxId) {
        this.taxId = taxId;
    }

    public String getDocGovIdPath() {
        return docGovIdPath;
    }

    public void setDocGovIdPath(String docGovIdPath) {
        this.docGovIdPath = docGovIdPath;
    }

    public String getDocBizCertPath() {
        return docBizCertPath;
    }

    public void setDocBizCertPath(String docBizCertPath) {
        this.docBizCertPath = docBizCertPath;
    }

    public String getDocAddressProofPath() {
        return docAddressProofPath;
    }

    public void setDocAddressProofPath(String docAddressProofPath) {
        this.docAddressProofPath = docAddressProofPath;
    }

    public String getAccountHolder() {
        return accountHolder;
    }

    public void setAccountHolder(String accountHolder) {
        this.accountHolder = accountHolder;
    }

    public String getBankName() {
        return bankName;
    }

    public void setBankName(String bankName) {
        this.bankName = bankName;
    }

    public String getAccountIban() {
        return accountIban;
    }

    public void setAccountIban(String accountIban) {
        this.accountIban = accountIban;
    }

    public boolean isAgreeTerms() {
        return agreeTerms;
    }

    public void setAgreeTerms(boolean agreeTerms) {
        this.agreeTerms = agreeTerms;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }

    public Long getReviewedBy() {
        return reviewedBy;
    }

    public void setReviewedBy(Long reviewedBy) {
        this.reviewedBy = reviewedBy;
    }

    public LocalDateTime getReviewedAt() {
        return reviewedAt;
    }

    public void setReviewedAt(LocalDateTime reviewedAt) {
        this.reviewedAt = reviewedAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}