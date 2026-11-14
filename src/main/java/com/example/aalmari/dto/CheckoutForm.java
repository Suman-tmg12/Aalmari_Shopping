package com.example.aalmari.dto;

/** Fields posted by checkout.jsp. Names match the name="" attributes in the form. */
public class CheckoutForm {
    private String fullName;
    private String phone;
    private String province;
    private String city;
    private String address;
    private String landmark;
    private String paymentMethod;
    private String orderNote;
    private String promoCode;
    private Long addressId;

    public Long getAddressId() { return addressId; }
    public void setAddressId(Long addressId) { this.addressId = addressId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getProvince() { return province; }
    public void setProvince(String province) { this.province = province; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getLandmark() { return landmark; }
    public void setLandmark(String landmark) { this.landmark = landmark; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getOrderNote() { return orderNote; }
    public void setOrderNote(String orderNote) { this.orderNote = orderNote; }
    public String getPromoCode() { return promoCode; }
    public void setPromoCode(String promoCode) { this.promoCode = promoCode; }
}