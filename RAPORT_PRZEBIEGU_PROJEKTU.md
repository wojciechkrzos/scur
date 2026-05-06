# Raport Z Przebiegu Projektu

## 1. Zakres I Metodyka

### 1.1. Cel Raportu
Celem raportu jest udokumentowanie zrealizowanych prac w projekcie gry S.C.U.R..

### 1.2. Zakres
- architekture aplikacji i przeplyw etapow,
- systemy rozgrywki (bullet heaven i bullet hell),
- system dialogowy (VN),
- interfejs i obsluge stanu gry,
- zasoby graficzne, fonty i dane dialogowe.

## 2. Obszary Prac Projektowych

### 2.1. Orkiestracja Gry I Przeplyw Etapow
Zaimplementowano centralny orchestrator, ktory uruchamia i przelacza moduly gry. Przeplyw etapu 1 jest sekwencyjny i obejmuje:
1. dialog tutorialowy,
2. segment bullet heaven,
3. dialog pre-boss,
4. walke z bossem,
5. dialog post-boss.

W przypadku porazki w segmencie walki etap jest powtarzany, co realizuje mechanike retry.

### 2.2. Globalny Stan Gry
Wprowadzono autoload z enumeracja stanow gry (menu, tryby walki, VN, pauza, game over) oraz sygnalizacja zmian stanu. Umozliwia to centralna kontrole logiki i czytelny podzial odpowiedzialnosci.

### 2.3. Gameplay: Bullet Heaven
Zrealizowano samodzielny modul survivalowy z limitem czasu, skalowaniem presji przeciwnikow i systemem progresji gracza.

### 2.4. Gameplay: Bullet Hell (Boss Fight)
Zrealizowano modul walki z bossem oparty o wzorce pociskow (patterns) oraz dwa warunki zwyciestwa: przetrwanie lub eliminacja bossa.

### 2.5. Warstwa Narracyjna (VN)
Wdrozone zostaly dialogi z efektem pisania, obsluga wyborow i skokow miedzy liniami, a takze kontekstowe tla i portrety postaci.

### 2.6. UI/UX I Obsluga Pauzy
Zaimplementowano menu startowe, menu pauzy i HUD-y dla obu modulow walki. Interfejs komunikuje stan rozgrywki, cele i wynik starcia.

### 2.7. Pipeline Danych I Assetow
Projekt posiada uporzadkowana strukture zasobow oraz zestaw plikow dialogowych i tutorialowych podlaczonych do runtime loadera.

## 3. Zrealizowane Funkcjonalnosci

### 3.1. Scena Glowna I Integracja Modulow
- Dynamiczne ladowanie scen i przejsc miedzy etapami.
- Obsluga startu przez menu i debugowych trybow uruchomienia.
- Spojny mechanizm zamykania etapu i przekazywania wyniku.

### 3.2. Mechaniki Bullet Heaven

#### 3.2.1. Parametry Walki I Tempo
- Czas etapu: 35 s.
- Dynamiczne przyspieszanie tempa spawnu przeciwnikow.
- Przewijany swiat i obszar gry o zadanym rozmiarze.

#### 3.2.2. Gracz
- Zycia i czasowa nietykalnosc po trafieniu.
- Automatyczne strzelanie.
- Sterowanie ruchem oraz animacja kierunkowa sprite-sheet.
- System doswiadczenia i poziomow.

#### 3.2.3. Bronie I Power-upy
Dostepne bronie/ulepszenia:
- Impuls (fala AoE),
- Strumien (seria pionowych pociskow),
- Spirala (obrotowy stream),
- Przyspieszenie (wzrost predkosci),
- Tarcza (dodatkowe zycie).

Model progresji oparto o losowy wybor 1 z 3 opcji podczas awansu poziomu.

#### 3.2.4. Przeciwnicy
Zaimplementowano trzy typy jednostek:
- Standard (podstawowy homing),
- Tank (wieksza wytrzymalosc),
- Swarm (szybkie jednostki liniowe, spawn eventowy).

#### 3.2.5. Kolizje I Obiekty Sceny
- Kolizje gracza z przeciwnikami i przeszkodami.
- Przeszkody statyczno-animowane (m.in. fontanna, golebie).
- Orb-y doswiadczenia jako pickup.

### 3.3. Mechaniki Bullet Hell

#### 3.3.1. Konfiguracja Starcia
- Staly prostokat pola gry.
- Dwa profile walki z bossem:
1. tryb KILL (boss A, skonczone HP),
2. tryb SURVIVE (boss B, limit czasu, bardzo wysokie HP).

#### 3.3.2. Gracz
- Tryb normal i focus (SHIFT) z roznymi predkosciami ruchu.
- Mala hitboxowa kolizja inspirowana konwencja touhou-like.
- Rozne profile strzalu dla normal/focus.
- Zycia i czasowa nietykalnosc po trafieniu.

#### 3.3.3. Boss I Patterny
Zaimplementowano system rotacji patternow z konfigurowalnymi parametrami czasu i szybkostrzelnosci. Dostepne wzorce obejmuja m.in. radial, spiral, aimed burst, cross wave, wall, random spread i warianty rozszerzone.

### 3.4. System VN, Dialogi I Wybory
- Typowanie tekstu znak-po-znaku.
- Efekt specjalny shake.
- Obsluga wyborow gracza i branchingu.
- Obsluga jump_to oraz kontekstowego tla dialogowego.
- Integracja wyniku wyboru z dalszym etapem (dialog post-boss zalezny od decyzji).

### 3.5. Interfejs Uzytkownika
- Start menu z dedykowanym tlem.
- Pause menu z dynamicznym tutorialem i celem aktualnego etapu.
- HUD Bullet Heaven: zycia, eliminacje, timer, poziom, PD, aktywny tryb.
- HUD Boss Fight: zycia, wynik punktowy, timer, HP bossa, ekran wyniku.

## 4. Inwentaryzacja Assetow

### 4.1. Assety Gameplayowe (Bullet Heaven)
- Tlo i podloga mapy,
- sprite animacji gracza,
- sprite przeszkod (fontanna, golebie),
- dodatkowy plik fountain.gif.

### 4.2. Assety Narracyjne (VN)
- 3 tla narracyjne (tutorial, pre-boss, post-boss),
- 3 portrety postaci (Szymon, Gosia, B.O.S.S.).

### 4.3. Assety UI I Typografia
- grafika menu startowego,
- font Pixelify Sans (wraz z importem Godot).

## 5. Dane Fabularne I Konfiguracyjne

### 5.1. Dane Dialogowe
Wydzielono osobne pliki dla:
- tutorialu,
- dialogu pre-boss,
- dialogu post-boss (zaleznosc od wyboru),
- scenariusza testowego.

### 5.2. Dane Tutorialowe
Zdefiniowano oddzielne instrukcje i cele dla trzech kontekstow: VN, bullet heaven, boss fight.

### 5.3. Konfiguracja Wejscia
Projekt ma jawnie skonfigurowane wejscia klawiaturowe dla ruchu (WASD), akcji potwierdzenia oraz pauzy.

## 6. Ocena Aktualnego Stanu Realizacji

### 6.1. Elementy Dostarczone
- Dzialajacy przeplyw etapu 1 od intro do post-boss.
- Dwa rozne moduly walki z odmienna dynamika.
- Integracja warstwy narracyjnej z rozgrywka.
- Podstawowe i czytelne UI wspierajace gameplay.
- Zestaw assetow pokrywajacy menu, VN i oba segmenty akcji.
