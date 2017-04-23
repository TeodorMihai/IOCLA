"C:\MinGW\bin\gcc.exe" -c main.c -o main.o
"C:\Program Files (x86)\SASM\NASM\nasm.exe" -g -f win32 calc.asm -o calc.o
"C:\MinGW\bin\gcc.exe" main.o calc.o -o calc