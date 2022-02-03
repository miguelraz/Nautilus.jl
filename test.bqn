↕10
+´3‿2‿1‿2
# text ← "abcabcbb"
text ← "abcabcbb"
{+´∧`∊text}¨↓text

FirstOddNNumbers ← 1+2×¨↕
FirstOddNNumbers 10

Prob2 ← {100×(+´65≤𝕩)÷≠𝕩}
Prob2 25‿90‿100‿64‿65

test3 ← "Testing one, two, three"
Prob3 ← +´=' '

test4 ← "((2x3)+4)"
Prob4 ← {"()"∊𝕩}
Prob4 test4

test5 ← 5
Prob5 ← =⌜˜↕
Prob5 5

test6 ← 9‿¯3‿7‿22‿7.6
# Addd the swirly to make it shape invariant
Prob6 ← (⌈´-⌊´)⥊
Prob6 test6

test7 ← 14.2‿9‿3‿3.1‿0‿1.1
Prob7 ← 3

# Make a multiplication table
Prob8 ← ×⌜˜1+↕

# n month moving averages
Prob9 ← (+´÷≠)˘↕

