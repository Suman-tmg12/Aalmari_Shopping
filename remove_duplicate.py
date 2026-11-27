import re
path = r"C:\Users\taman\Downloads\Aalmari_Shopping\src\main\java\com\example\aalmari\repository\SellerProductRepository.java"
with open(path, "r", encoding="utf-8") as f:
    text = f.read()
pattern = re.compile(r'\n    @Query\("""(?:(?!\n    @Query).)*?WHERE p\.id = :id AND p\.active = true(?:(?!\n    @Query).)*?Optional<SellerProduct> findPublicActiveById\(@Param\("id"\) Long id\);\n', re.DOTALL)
matches = list(pattern.finditer(text))
print("matches", len(matches))
if len(matches) > 1:
    match = matches[-1]
    text = text[:match.start()] + text[match.end():]
with open(path, "w", encoding="utf-8", newline="") as f:
    f.write(text)

