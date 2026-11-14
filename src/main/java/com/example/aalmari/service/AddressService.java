package com.example.aalmari.service;

import com.example.aalmari.model.Address;
import com.example.aalmari.repository.AddressRepository;
import com.example.aalmari.repository.UserRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

@Service
public class AddressService {

    public static final int MAX_ADDRESSES = 10;
    private static final Set<String> LABELS = Set.of("Home", "Office", "Other");
    private static final Set<String> PROVINCES = Set.of(
            "Koshi", "Madhesh", "Bagmati", "Gandaki", "Lumbini", "Karnali", "Sudurpashchim");

    /** What the checkout page needs for one saved address (serialized to JSON). */
    public record View(Long id, String label, String name, String phone, String province,
                       String city, String street, String landmark, boolean primary) {}

    private final AddressRepository addressRepository;
    private final UserRepository userRepository;
    private final ObjectMapper mapper = new ObjectMapper();

    public AddressService(AddressRepository addressRepository, UserRepository userRepository) {
        this.addressRepository = addressRepository;
        this.userRepository = userRepository;
    }

    private static IllegalArgumentException bad(String m) { return new IllegalArgumentException(m); }

    @Transactional(readOnly = true)
    public List<View> list(Long userId) {
        List<View> out = new ArrayList<>();
        for (Address a : addressRepository.findByUser_IdOrderByDefaultAddressDescIdDesc(userId)) {
            out.add(new View(a.getId(), a.getLabel(), a.getReceiverName(), a.getPhone(),
                    a.getProvince(), a.getCity(), a.getStreet(),
                    a.getLandmark() == null ? "" : a.getLandmark(), a.isDefaultAddress()));
        }
        return out;
    }

    @Transactional(readOnly = true)
    public String listJson(Long userId) {
        try {
            return mapper.writeValueAsString(list(userId));
        } catch (JsonProcessingException e) {
            return "[]";
        }
    }

    /** Creates (id == null) or edits an address. Returns its id. */
    @Transactional
    public Long save(Long userId, Long id, String label, String name, String phone,
                     String province, String city, String street, String landmark,
                     boolean makeDefault) {

        label = trim(label); name = trim(name); phone = trim(phone);
        province = trim(province); city = trim(city); street = trim(street); landmark = trim(landmark);

        if (!LABELS.contains(label)) throw bad("Choose Home, Office or Other.");
        if (name.length() < 2 || name.length() > 150) throw bad("Enter the receiver's name.");
        if (!phone.matches("9[678][0-9]{8}")) throw bad("Enter a 10-digit mobile number starting with 96, 97 or 98.");
        if (!PROVINCES.contains(province)) throw bad("Select a province.");
        if (city.length() < 2 || city.length() > 100) throw bad("Enter your city or municipality.");
        if (street.length() < 3 || street.length() > 255) throw bad("Enter your street address.");
        if (landmark.length() > 255) throw bad("Landmark is too long.");

        boolean first = id == null && addressRepository.countByUser_Id(userId) == 0;
        if (id == null && addressRepository.countByUser_Id(userId) >= MAX_ADDRESSES) {
            throw bad("You can save up to " + MAX_ADDRESSES + " addresses. Delete one first.");
        }

        boolean setDefault = makeDefault || first;
        if (setDefault) addressRepository.clearDefault(userId);

        Address a;
        if (id == null) {
            a = new Address();
            a.setUser(userRepository.getReferenceById(userId));
        } else {
            a = addressRepository.findByIdAndUser_Id(id, userId)
                    .orElseThrow(() -> bad("Address not found."));
        }

        a.setLabel(label);
        a.setReceiverName(name);
        a.setPhone(phone);
        a.setProvince(province);
        a.setCity(city);
        a.setStreet(street);
        a.setLandmark(landmark.isEmpty() ? null : landmark);
        if (setDefault) a.setDefaultAddress(true);

        return addressRepository.save(a).getId();
    }

    @Transactional
    public void delete(Long userId, Long id) {
        Address a = addressRepository.findByIdAndUser_Id(id, userId)
                .orElseThrow(() -> bad("Address not found."));
        boolean wasDefault = a.isDefaultAddress();
        addressRepository.delete(a);
        addressRepository.flush();

        if (wasDefault) {   // promote the newest remaining address
            addressRepository.findByUser_IdOrderByDefaultAddressDescIdDesc(userId)
                    .stream().findFirst()
                    .ifPresent(n -> n.setDefaultAddress(true));
        }
    }

    @Transactional
    public void setDefault(Long userId, Long id) {
        addressRepository.findByIdAndUser_Id(id, userId)
                .orElseThrow(() -> bad("Address not found."));
        addressRepository.clearDefault(userId);
        addressRepository.findByIdAndUser_Id(id, userId)
                .ifPresent(a -> a.setDefaultAddress(true));
    }

    private static String trim(String s) { return s == null ? "" : s.trim(); }
}