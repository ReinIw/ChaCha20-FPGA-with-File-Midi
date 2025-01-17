def decrypt_midi_file(midi_path, keystream_path, output_path):
    try:
        # Baca seluruh file MIDI yang telah dikorupsi
        with open(midi_path, "rb") as midi_file:
            midi_data = midi_file.read()  # Baca seluruh byte

        # Ambil 64 byte pertama dari file MIDI
        first_64_bytes = midi_data[:64]  # 64 byte pertama

        # Baca keystream dari file HexKeystream.txt
        with open(keystream_path, "r", encoding="utf-8") as keystream_file:
            keystream_hex = keystream_file.read().replace("\n", "").strip()

        # Lakukan XOR untuk 64 byte pertama dengan keystream
        xor_result = bytearray()
        for i in range(64):
            # Ambil byte ke-i dari MIDI dan keystream, lakukan XOR
            xor_result.append(first_64_bytes[i] ^ int(keystream_hex[i*2:i*2+2], 16))

        # Ambil sisa byte setelah 64 byte pertama tanpa melakukan XOR
        remaining_bytes = midi_data[64:]

        # Gabungkan hasil XOR 64 byte pertama dan sisa byte
        full_data = xor_result + remaining_bytes

        # Simpan hasilnya ke file output baru
        with open(output_path, "wb") as output_file:
            output_file.write(full_data)

        print(f"Data telah didekripsi dan disimpan ke {output_path}")

    except Exception as e:
        print(f"Kesalahan saat mendekripsi file: {e}")

# Path file yang digunakan
midi_file_path = "BalonkuRusak.mid"
keystream_file_path = "HexKeystream.txt"
output_file_path = "BalikBalonk.mid"

# Panggil fungsi dekripsi
decrypt_midi_file(midi_file_path, keystream_file_path, output_file_path)
