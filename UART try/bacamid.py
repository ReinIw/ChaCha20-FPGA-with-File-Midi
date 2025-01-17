file_path_midi = "BalikBalonk.mid"  # Ganti dengan path file MIDI Anda
with open(file_path_midi, "rb") as file_midi:
    midi_data = file_midi.read()
    print("Midi terbaca : ")
# Konversi ke hexadecimal
midi_hex = midi_data.hex()
print(midi_hex[:512])  # Menampilkan 128 karakter hexadecimal psertama
print()