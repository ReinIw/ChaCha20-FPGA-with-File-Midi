import serial
import time

# Konfigurasi serial
SERIAL_PORT = 'COM8'  # Ganti sesuai dengan port yang Anda gunakan
BAUD_RATE = 9600      # Harus sesuai dengan pengaturan baud rate FPGA

file_path = "HexKeystream.txt"

def xor_midi_with_keystream(midi_path, keystream_path):
    try:
        # Baca 128 karakter pertama dari file MIDI asli
        with open(midi_path, "rb") as midi_file:
            midi_data = midi_file.read(64)  # Hanya ambil 128 byte pertama

        # Konversi ke hexadecimal
        midi_hex = midi_data.hex()

        # Baca keystream dari file HexKeystream.txt (128 karakter pertama)
        with open(keystream_path, "r", encoding="utf-8") as keystream_file:
            keystream_hex = keystream_file.read().strip().replace("\n", "")

        # Pastikan panjang keystream dan MIDI sesuai
        if len(midi_hex) != 128 or len(keystream_hex) != 128:
            print(f"Panjang data MIDI: {len(midi_hex)}, Panjang keystream: {len(keystream_hex)}")
            raise ValueError("Panjang data MIDI atau keystream tidak sesuai. Pastikan keduanya 128 karakter.")

        # XOR antara kedua string hexadecimal
        xor_result = int(midi_hex, 16) ^ int(keystream_hex, 16)

        # Konversi hasil XOR ke hexadecimal
        xor_result_hex = f"{xor_result:032X}"  # Hasil XOR dalam format 128-bit hex (32 digit)

        print(f"Hasil XOR (Hexadecimal): {xor_result_hex}")

        # Mengembalikan hasil XOR (sebagai daftar string hexadecimal)
        return [xor_result_hex[i:i+8] for i in range(0, len(xor_result_hex), 8)]
        
    except Exception as e:
        print(f"Kesalahan saat melakukan XOR: {e}")
        return []

def corrupt_midi_file(original_midi_path, xor_results):
    try:
        # Baca file MIDI asli dalam mode biner
        with open(original_midi_path, "rb") as file:
            original_midi_data = bytearray(file.read())  # Gunakan bytearray agar dapat dimodifikasi
        
        # Lakukan penggantian byte dengan hasil XOR
        for i in range(len(xor_results)):
            if i * 4 < len(original_midi_data):  # Pastikan tidak keluar dari panjang data asli
                # Konversi hasil XOR (string hex) menjadi 4 byte
                xor_bytes = int(xor_results[i], 16).to_bytes(4, byteorder="big")
                original_midi_data[i * 4:(i * 4) + 4] = xor_bytes

        # Tulis data yang sudah diubah ke file baru
        corrupted_midi_path = "BalonkuRusak.mid"
        with open(corrupted_midi_path, "wb") as corrupted_file:
            corrupted_file.write(original_midi_data)

        print(f"File MIDI telah dikorupsi dan disimpan ke {corrupted_midi_path}")
    except Exception as e:
        print(f"Kesalahan saat mengkorupsi file MIDI: {e}")

def write_to_file(data_lines):
    try:
        with open(file_path, "w") as file:
            file.writelines(data_lines)
        print(f"Data telah ditulis ke {file_path}")
    except Exception as e:
        print(f"Kesalahan saat menulis ke file: {e}")

def lcg_single_96bit_binary() -> int:
    """
    Fungsi LCG untuk menghasilkan satu bilangan acak 96-bit.
    """
    seed = int(time.time() * 1000)  # Konversi waktu ke integer dan dikalikan dengan 1000
    a = 2654435761  # Multiplier
    c = 12345       # Increment
    m = 2**96       # Modulus untuk menghasilkan bilangan 96-bit

    # Hitung bilangan acak
    seed = (a * seed + c) % m
    return seed

def send_and_receive_data():
    # Baca Hex midi file 
    # Baca file MIDI dalam mode biner
    file_path_midi = "Balonku.mid"  # Ganti dengan path file MIDI Anda
    with open(file_path_midi, "rb") as file_midi:
        midi_data = file_midi.read()
        print("Midi terbaca : ")

    # Konversi ke hexadecimal
    midi_hex = midi_data.hex()
    print(midi_hex[:128])  # Menampilkan 128 karakter hexadecimal pertama
    print()

    # inisialisasi LCG 
    hasil = lcg_single_96bit_binary()
    print("Bilangan acak 96-bit dalam format integer:")
    print(hasil)
    print(f"{hasil:096b}") 
    time.sleep(1)
    print()
    
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

    # Inisialisasi koneksi serial
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=5)
        print(f"Koneksi serial dibuka di {SERIAL_PORT} dengan baud rate {BAUD_RATE}")
    except serial.SerialException as e:
        print(f"Gagal membuka koneksi serial: {e}")
        return

    # Data mentah 512 bit (64 byte) dari input pengguna 
    binary_data_to_send = bytes([
    0b01100001, 0b01110000, 0b01111000, 0b01100101, 0b00110011, 0b00100000, 0b01100100, 0b01101110,
    0b01111001, 0b01100010, 0b00101101, 0b00110010, 0b01101011, 0b00100000, 0b01100101, 0b01110100,
    0b00000011, 0b00000010, 0b00000001, 0b00000000, 0b00000111, 0b00000110, 0b00000101, 0b00000100,
    0b00001011, 0b00001010, 0b00001001, 0b00001000, 0b00001111, 0b00001110, 0b00001101, 0b00001100,
    0b00010011, 0b00010010, 0b00010001, 0b00010000, 0b00010111, 0b00010110, 0b00010101, 0b00010100,
    0b00011011, 0b00011010, 0b00011001, 0b00011000, 0b00011111, 0b00011110, 0b00011101, 0b00011100,
    0b00000000, 0b00000000, 0b00000000, 0b00000001, 0b00001001, 0b00000000, 0b00000000, 0b00000000,
    0b01001010, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000
    ])
    
    print("Data yang akan dikirim (biner):")
    print(' '.join(f'{byte:08b}' for byte in binary_data_to_send))

    received_data = None
    try:
        # Kirim data ke FPGA
        ser.write(binary_data_to_send)
        print("Data biner berhasil dikirim.")

        # Tunggu sebentar untuk menerima balasan
        time.sleep(10)

        # Terima data dari FPGA
        received_data = ser.read(64)  # Membaca 64 byte data
        if received_data:
            print("Data mentah yang diterima (biner):")
            print(' '.join(f'{byte:08b}' for byte in received_data))
        else:
            print("Tidak ada data yang diterima.")

    except Exception as e:
        print(f"Kesalahan selama komunikasi: {e}")
    finally:
        # Tutup koneksi serial
        ser.close()
        print("Koneksi serial ditutup.")
    
    # Jika data diterima, lakukan penjumlahan
    if received_data:
        binary_data_receive = []
    
        # Penjumlahan setiap 4 byte (32 bit)
        for i in range(0, len(binary_data_to_send), 4):
            send_32bit = int.from_bytes(binary_data_to_send[i:i+4], byteorder='big')
            receive_32bit = int.from_bytes(received_data[i:i+4], byteorder='big')
            
           
            binary_data_receive.append(receive_32bit)

            send_hex = f"{send_32bit:08X}"
            receive_hex = f"{receive_32bit:08X}"
         

            reversed_hex = ''.join(reversed([receive_hex[i:i+2] for i in range(0, 8, 2)]))

            print(f"\nData yang dikirim (32 bit): {send_32bit:032b}")
            print(f"Data yang dikirim (HEX): {send_hex}")
            print(f"Data yang diterima (32 bit): {receive_32bit:032b}")
            print(f"Data yang diterima (HEX): {receive_hex}")
            print(f"Hasil hexadecimal dibalik: {reversed_hex}")

        data_lines = []
        print("\nHasil penjumlahan seluruh data (hex dibalik):")
        for value in binary_data_receive:
            receive_hex = f"{value:08X}"
            reversed_hex = ''.join(reversed([receive_hex[i:i+2] for i in range(0, 8, 2)]))
            print(reversed_hex)
            data_lines.append(reversed_hex + "\n")
        write_to_file(data_lines)

        # XOR dengan midi Hex dan tampilkan hasilnya
        midi_xor_results = xor_midi_with_keystream(file_path_midi, file_path)

        print("\nHasil XOR (Hexadecimal):")
        for result in midi_xor_results:
            print(result)

        # Simpan hasil XOR ke file
        try:
            xor_file_path = "HexXORResults.txt"
            with open(xor_file_path, "w") as xor_file:
                xor_file.write('\n'.join(midi_xor_results) + "\n")
            print(f"Hasil XOR telah disimpan ke {xor_file_path}")
        except Exception as e:
            print(f"Kesalahan saat menyimpan hasil XOR: {e}")
       
        # Korupsi file MIDI dengan hasil XOR
        corrupt_midi_file(file_path_midi, midi_xor_results)


if __name__ == "__main__":
    send_and_receive_data()
