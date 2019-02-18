import studio
import sys

y = input ("enter the year")
m = input ("enter the month")
d = input ("enter the day")
y = y − (14 − m)//12
x = y + y//4 − y//100 + y//400
m = m + 12 × ((14 − m)//12) − 2
D = (d + x + 31 × m//12) % 7
print (D)

