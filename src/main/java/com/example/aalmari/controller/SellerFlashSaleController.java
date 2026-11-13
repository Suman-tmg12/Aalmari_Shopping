package com.example.aalmari.controller;

import com.example.aalmari.service.FlashSaleService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.function.Function;

@Controller
public class SellerFlashSaleController {

    private final FlashSaleService flashSaleService;

    public SellerFlashSaleController(FlashSaleService flashSaleService) {
        this.flashSaleService = flashSaleService;
    }

    @PostMapping(value = "/api/flashsales/save", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> save(@RequestBody FlashSaleService.SaveReq req, HttpSession session) {
        return run(session, uid -> { flashSaleService.save(uid, req); return "Saved."; });
    }

    @PostMapping("/api/flashsales/end")
    public ResponseEntity<String> end(@RequestParam("id") Long id, HttpSession session) {
        return run(session, uid -> { flashSaleService.end(uid, id); return "Ended."; });
    }

    @PostMapping("/api/flashsales/delete")
    public ResponseEntity<String> delete(@RequestParam("id") Long id, HttpSession session) {
        return run(session, uid -> { flashSaleService.delete(uid, id); return "Deleted."; });
    }

    private ResponseEntity<String> run(HttpSession session, Function<Long, String> action) {
        Object a = session.getAttribute("userId");
        if (a == null) return ResponseEntity.status(401).body("Unauthorized");
        try {
            return ResponseEntity.ok(action.apply(Long.valueOf(a.toString())));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (SecurityException e) {
            return ResponseEntity.status(403).body(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }
}