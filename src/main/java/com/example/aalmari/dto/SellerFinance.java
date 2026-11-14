package com.example.aalmari.dto;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** Everything the seller dashboard + finance view need, computed from delivered orders. */
public class SellerFinance {

    public static final int MONTHS = 6;
    private static final DateTimeFormatter MMM = DateTimeFormatter.ofPattern("MMM", Locale.ENGLISH);

    public static class Earn {
        public String name;
        public long amount;           // net, after commission
    }

    public static class Payout {
        public String period;         // "Oct 1–31"
        public String ref;            // "PAY-202610"
        public String date;           // "Nov 5"
        public long net;
        public boolean paid;
    }

    public String[] months;           // oldest -> current
    public long[] gross;
    public int[] orders;              // distinct delivered orders per month
    public double commissionRate;
    public String currentMonthLabel;  // "November 2026"
    public String rangeLabel;         // "June – November 2026"
    public String currentPeriod;      // "Nov 1–30"
    public String nextPayoutDate;     // "Dec 5"
    public List<Earn> earnings = new ArrayList<>();
    public List<Payout> payouts = new ArrayList<>();

    public static SellerFinance empty() {
        return blank(LocalDate.now(), 0.10);
    }

    public static SellerFinance blank(LocalDate today, double rate) {
        SellerFinance f = new SellerFinance();
        YearMonth cur = YearMonth.from(today);
        YearMonth first = cur.minusMonths(MONTHS - 1);

        f.commissionRate = rate;
        f.months = new String[MONTHS];
        f.gross = new long[MONTHS];
        f.orders = new int[MONTHS];
        for (int k = 0; k < MONTHS; k++) {
            f.months[k] = cur.minusMonths(MONTHS - 1 - k).format(MMM);
        }
        f.currentMonthLabel = cur.format(DateTimeFormatter.ofPattern("MMMM yyyy", Locale.ENGLISH));
        f.rangeLabel = first.format(DateTimeFormatter.ofPattern("MMMM", Locale.ENGLISH)) + " – " + f.currentMonthLabel;
        f.currentPeriod = periodLabel(cur);
        f.nextPayoutDate = payoutDate(cur).format(DateTimeFormatter.ofPattern("MMM d", Locale.ENGLISH));
        return f;
    }

    public static String periodLabel(YearMonth ym) {
        return ym.format(MMM) + " 1–" + ym.lengthOfMonth();
    }

    /** Payout for a month is released on the 5th of the next month. */
    public static LocalDate payoutDate(YearMonth ym) {
        return ym.plusMonths(1).atDay(5);
    }
}