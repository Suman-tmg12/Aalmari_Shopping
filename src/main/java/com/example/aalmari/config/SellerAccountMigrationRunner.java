package com.example.aalmari.config;

import com.example.aalmari.model.SellerDocumentation;
import com.example.aalmari.repository.SellerDocumentationRepository;
import com.example.aalmari.service.CryptoService;
import com.example.aalmari.util.MaskUtil;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.jdbc.core.JdbcTemplate;

import java.util.List;

@Component
public class SellerAccountMigrationRunner implements CommandLineRunner {

    private final SellerDocumentationRepository repository;
    private final CryptoService cryptoService;
    private final JdbcTemplate jdbcTemplate;

    public SellerAccountMigrationRunner(SellerDocumentationRepository repository,
                                        CryptoService cryptoService,
                                        JdbcTemplate jdbcTemplate) {
        this.repository = repository;
        this.cryptoService = cryptoService;
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(String... args) {
        // Expand the account_iban column to VARCHAR(512) before migration
        jdbcTemplate.execute("ALTER TABLE seller_documentation MODIFY COLUMN account_iban VARCHAR(512)");

        Integer maskedColumnCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM information_schema.COLUMNS "
                        + "WHERE TABLE_SCHEMA = DATABASE() "
                        + "AND TABLE_NAME = 'seller_documentation' "
                        + "AND COLUMN_NAME = 'account_iban_masked'",
                Integer.class);
        if (maskedColumnCount == null || maskedColumnCount == 0) {
            jdbcTemplate.execute("ALTER TABLE seller_documentation ADD COLUMN account_iban_masked VARCHAR(50)");
        } else {
            jdbcTemplate.execute("ALTER TABLE seller_documentation MODIFY COLUMN account_iban_masked VARCHAR(50)");
        }

        List<SellerDocumentation> rows = repository.findAll();
        for (SellerDocumentation doc : rows) {
            if (doc.getAccountIbanMasked() != null && !doc.getAccountIbanMasked().isBlank()) {
                continue;
            }

            String stored = doc.getAccountIban();
            if (stored == null || stored.isBlank()) {
                continue;
            }

            // If a row is already encrypted, do not re-encrypt it.
            try {
                String decrypted = cryptoService.decrypt(stored);
                if (decrypted != null && !decrypted.isBlank() && decrypted.matches("\\d{8,34}")) {
                    doc.setAccountIbanMasked(MaskUtil.maskAccountNumber(decrypted));
                    repository.save(doc);
                    continue;
                }
            } catch (IllegalStateException ignored) {
                // Stored value is a legacy plain account number.
            }

            String plain = stored.replaceAll("[\\s-]", "");
            if (!plain.matches("\\d{8,34}")) {
                continue;
            }

            doc.setAccountIban(cryptoService.encrypt(plain));
            doc.setAccountIbanMasked(MaskUtil.maskAccountNumber(plain));
            repository.save(doc);
        }
    }
}
