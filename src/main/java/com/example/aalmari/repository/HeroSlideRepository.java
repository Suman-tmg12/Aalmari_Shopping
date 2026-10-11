package com.example.aalmari.repository;

import com.example.aalmari.dto.HeroSlide;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@Repository
public class HeroSlideRepository {

    private final String dbUrl = "jdbc:mysql://localhost:3306/Aalmari_shopping";
    private final String dbUser = "root";
    private final String dbPassword = "suman";

    public List<HeroSlide> findAllActiveSlides() {
        List<HeroSlide> slides = new ArrayList<>();
        String sql = "SELECT * FROM hero_slides WHERE active = 1 ORDER BY priority ASC";

        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                HeroSlide slide = new HeroSlide();
                slide.setId(rs.getLong("id"));
                slide.setActive(rs.getBoolean("active"));
                slide.setCtaText(rs.getString("cta_text"));
                slide.setCtaUrl(rs.getString("cta_url"));
                slide.setImageUrl(rs.getString("image_url"));
                slide.setPriority(rs.getInt("priority"));
                slide.setSubtitle(rs.getString("subtitle"));
                slide.setTitle(rs.getString("title"));
                slides.add(slide);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return slides;
    }
}