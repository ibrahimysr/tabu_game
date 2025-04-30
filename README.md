# 🎮 Flutter Tabu Oyunu


Flutter ile geliştirilmiş, eğlenceli ve interaktif bir Tabu kelime oyunu. Arkadaşlarınızla birlikte oynayabileceğiniz, yasaklı kelimeleri kullanmadan anlatmaya çalıştığınız bu klasik oyunu cep telefonunuza taşıyın!

## 📱 Ekran Görüntüleri

<table>
    <tr>
    <td>Başlangıç Ekranı</td>
    <td>Oyun Ayarları</td>
    <td>Oyun Ekranı</td>
  </tr>
  <tr>
    <td><img src="https://i.imgur.com/OupdDBY.png" alt="Başlangıç Ekranı" /></td>
    <td><img src="https://i.imgur.com/nYBPtil.png" alt="Oyun Ayarları" /></td>
    <td><img src="https://i.imgur.com/v8IuhAY.png" alt="Takım Oluşturma" /></td>
  </tr>
</table>

## ✨ Özellikler

- 🎭 2 veya daha fazla takım ile oynama
- 🎲 Türkçe kapsamlı kelime veritabanı 
- ⏱️ Ayarlanabilir oyun süresi
- 🏆 Skor takibi ve istatistikler
- 📱 Tam duyarlı tasarım (tüm ekran boyutlarına uygun)
- 🌐 Çevrimdışı oynama desteği

## 🛠️ Teknik Özellikler

### Kullanılan Teknolojiler

- [Flutter](https://flutter.dev/) - UI framework
- [Dart](https://dart.dev/) - Programlama dili
- [SharedPrefences](https://pub.dev/packages/shared_preferences) - Animasyonlar

## Kurulum

```bash
# Repo'yu klonlayın
git clone https://github.com/ibrahimysr/tabu_game.git

# Proje dizinine gidin
cd tabu_game

# Bağımlılıkları yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run
```

## 🎯 Nasıl Oynanır

1. Ana menüden "Yeni Oyun" seçeneğini seçin
2. Takım sayısını ve isimlerini belirleyin
3. Oyun süresini ve diğer ayarları yapılandırın
4. Oyuna başlayın
5. Sıradaki oyuncu, ekranda gördüğü ana kelimeyi, yasaklı 5 kelimeyi kullanmadan takım arkadaşlarına anlatmaya çalışır
6. Takım arkadaşları kelimeyi doğru tahmin ederse ✓ butonuna, yasaklı kelime kullanılırsa ✗ butonuna basılır
7. Süre dolana kadar devam edin
8. Sıra diğer takıma geçer

## ⚙️ Özelleştirme Seçenekleri

- **Takım İsimleri**: Takımlarının İsimlendirilmesi
- **Oyun Süresi**: İstenilen Süre 
- **Tur Sayısı**: Oynanıcak Tur Sayısı

