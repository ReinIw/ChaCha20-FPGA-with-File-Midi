import time

def lcg_single_96bit_binary() -> int:
    """
    Fungsi LCG untuk menghasilkan satu bilangan acak 96-bit.

    Returns:
        int: Bilangan acak 96-bit dalam format integer.
    """
    seed = int(time.time() * 1000)  # Konversi waktu ke integer dan dikalikan dengan 1000
    a = 2654435761  # Multiplier
    c = 12345       # Increment
    m = 2**96       # Modulus untuk menghasilkan bilangan 96-bit

    # Hitung bilangan acak
    seed = (a * seed + c) % m
    return seed

# Menghasilkan bilangan acak berdasarkan waktu
hasil = lcg_single_96bit_binary()
# Menampilkan hasil
print("Bilangan acak 96-bit dalam format integer:")
print(hasil)
print(f"{hasil:096b}") 

# Mengonversi hasil menjadi array byte
hasil_bytes = [
    (hasil >> 88) & 0xFF,
    (hasil >> 80) & 0xFF,
    (hasil >> 72) & 0xFF,
    (hasil >> 64) & 0xFF,
    (hasil >> 56) & 0xFF,
    (hasil >> 48) & 0xFF,
    (hasil >> 40) & 0xFF,
    (hasil >> 32) & 0xFF,
    (hasil >> 24) & 0xFF,
    (hasil >> 16) & 0xFF,
    (hasil >> 8) & 0xFF,
    hasil & 0xFF,
]

# Membuat array binary_data_to_send
binary_data_to_send = bytes([
    0b01100001, 0b01110000, 0b01111000, 0b01100101, 0b00110011, 0b00100000, 0b01100100, 0b01101110,
    0b01111001, 0b01100010, 0b00101101, 0b00110010, 0b01101011, 0b00100000, 0b01100101, 0b01110100,
    0b00000011, 0b00000010, 0b00000001, 0b00000000, 0b00000111, 0b00000110, 0b00000101, 0b00000100,
    0b00001011, 0b00001010, 0b00001001, 0b00001000, 0b00001111, 0b00001110, 0b00001101, 0b00001100,
    0b00010011, 0b00010010, 0b00010001, 0b00010000, 0b00010111, 0b00010110, 0b00010101, 0b00010100,
    0b00011011, 0b00011010, 0b00011001, 0b00011000, 0b00011111, 0b00011110, 0b00011101, 0b00011100,
    0b00000000, 0b00000000, 0b00000000, 0b00000001,
    *hasil_bytes  # Menambahkan byte hasil ke array
])

# Menampilkan array binary secara menurun
print("\nArray binary secara menurun:")
for byte in binary_data_to_send:
    print(f"{byte:08b}")

# saya ingin binary_data_send disimpan di new plaintext buat file baru 
with open("binary_data_send_plaintext.txt", "w") as file:
    for byte in binary_data_to_send:
        file.write(f"{byte:08b}\n")