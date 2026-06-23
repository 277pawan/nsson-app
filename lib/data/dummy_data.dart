import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'models.dart';

class DummyData {
  DummyData._();

  static const List<Brand> brands = [
    Brand(id: 'nsson', name: 'NSSON', logo: 'assets/logo.png'),
    Brand(
        id: 'hero',
        name: 'Hero',
        logo: 'https://picsum.photos/seed/hero/200/200'),
    Brand(
        id: 'honda',
        name: 'Honda',
        logo: 'https://picsum.photos/seed/honda/200/200'),
    Brand(
        id: 'tvs', name: 'TVS', logo: 'https://picsum.photos/seed/tvs/200/200'),
    Brand(
        id: 'bajaj',
        name: 'Bajaj',
        logo: 'https://picsum.photos/seed/bajaj/200/200'),
    Brand(
        id: 'royal_enfield',
        name: 'Royal Enfield',
        logo: 'https://picsum.photos/seed/royalenfield/200/200'),
    Brand(
        id: 'universal',
        name: 'Universal',
        logo: 'https://picsum.photos/seed/universal/200/200'),
  ];

  static const List<Category> categories = [
    Category(id: 'fiber', name: 'Fiber Parts', icon: Icons.layers_rounded),
    Category(id: 'body', name: 'Body Parts', icon: Icons.shield_outlined),
    Category(id: 'engine', name: 'Engine Parts', icon: Icons.settings_rounded),
    Category(
        id: 'braking',
        name: 'Braking System',
        icon: Icons.stop_circle_outlined),
    Category(
        id: 'electrical',
        name: 'Electricals',
        icon: Icons.electric_bolt_rounded),
    Category(
        id: 'tyres', name: 'Tyres & Tubes', icon: Icons.trip_origin_rounded),
    Category(
        id: 'lubricants', name: 'Lubricants', icon: Icons.water_drop_outlined),
  ];

  static const List<Product> products = [
    Product(
      id: 'hero-headlight-visor-splendor',
      name: 'Headlight Visor (Mask)',
      partNumber: 'HERO-SPL-MASK-AM',
      brand: 'hero',
      category: 'fiber',
      price: 250,
      stock: 180,
      image: 'https://picsum.photos/seed/hero-mask/400/400',
      images: ['https://picsum.photos/seed/hero-mask-2/400/400'],
      description:
          'Aftermarket headlight visor for Hero Splendor Plus and Splendor Pro. User-facing price set near the midpoint of the given range. OEM range: Rs 450-600.',
    ),
    Product(
      id: 'hero-chain-sprocket-kit',
      name: 'Chain Sprocket Kit',
      partNumber: 'HERO-CSK-SPL-PAS-HF',
      brand: 'hero',
      category: 'engine',
      price: 600,
      stock: 220,
      image: 'https://picsum.photos/seed/hero-csk/400/400',
      images: ['https://picsum.photos/seed/hero-csk-2/400/400'],
      description:
          'Fast-moving Hero kit compatible with Splendor, Passion and HF series. OEM range: Rs 850-1,050.',
    ),
    Product(
      id: 'hero-shock-absorber-rear',
      name: 'Shock Absorber (Rear Pair)',
      partNumber: 'HERO-SHOCK-SPL-PAIR',
      brand: 'hero',
      category: 'body',
      price: 1300,
      stock: 90,
      image: 'https://picsum.photos/seed/hero-shock/400/400',
      images: ['https://picsum.photos/seed/hero-shock-2/400/400'],
      description:
          'Rear shock absorber pair for Hero Splendor. Mid-market aftermarket price for fast retail sale. OEM range: Rs 1,800-2,200.',
    ),
    Product(
      id: 'hero-indicator-assembly-set',
      name: 'Indicator Assembly (Set of 4)',
      partNumber: 'HERO-IND-UNI-SET4',
      brand: 'hero',
      category: 'electrical',
      price: 400,
      stock: 160,
      image: 'https://picsum.photos/seed/hero-indicator/400/400',
      images: ['https://picsum.photos/seed/hero-indicator-2/400/400'],
      description:
          'Universal Hero indicator assembly set for commuter models. OEM range: Rs 700-900.',
    ),
    Product(
      id: 'hero-clutch-plate',
      name: 'Clutch Plate',
      partNumber: 'HERO-CLT-SPL-PAS',
      brand: 'hero',
      category: 'engine',
      price: 315,
      stock: 175,
      image: 'https://picsum.photos/seed/hero-clutch/400/400',
      images: ['https://picsum.photos/seed/hero-clutch-2/400/400'],
      description:
          'Hero Splendor and Passion clutch plate set for routine service demand. OEM range: Rs 650-800.',
    ),
    Product(
      id: 'hero-side-panel-set',
      name: 'Side Panel Set',
      partNumber: 'HERO-SIDE-SPL-SET',
      brand: 'hero',
      category: 'fiber',
      price: 500,
      stock: 100,
      image: 'https://picsum.photos/seed/hero-sidepanel/400/400',
      images: ['https://picsum.photos/seed/hero-sidepanel-2/400/400'],
      description:
          'Fiber side panel set for Hero Splendor Plus. OEM range: Rs 850-1,100.',
    ),
    Product(
      id: 'hero-carburetor-assembly',
      name: 'Carburetor Assembly',
      partNumber: 'HERO-CARB-SPLPRO-HF',
      brand: 'hero',
      category: 'engine',
      price: 2000,
      stock: 55,
      image: 'https://picsum.photos/seed/hero-carb/400/400',
      images: ['https://picsum.photos/seed/hero-carb-2/400/400'],
      description:
          'Carburetor assembly for Hero Splendor Pro and HF Deluxe. OEM range: Rs 3,500-4,500.',
    ),
    Product(
      id: 'hero-speedometer-assembly',
      name: 'Speedometer Assembly',
      partNumber: 'HERO-SPD-ANA-SPL',
      brand: 'hero',
      category: 'electrical',
      price: 525,
      stock: 70,
      image: 'https://picsum.photos/seed/hero-speedo/400/400',
      images: ['https://picsum.photos/seed/hero-speedo-2/400/400'],
      description:
          'Analog speedometer assembly for Hero Splendor. OEM range: Rs 950-1,200.',
    ),
    Product(
      id: 'hero-fuel-tank-cap',
      name: 'Fuel Tank Cap',
      partNumber: 'HERO-TANKCAP-SPL-PAS',
      brand: 'hero',
      category: 'body',
      price: 175,
      stock: 220,
      image: 'https://picsum.photos/seed/hero-tankcap/400/400',
      images: ['https://picsum.photos/seed/hero-tankcap-2/400/400'],
      description:
          'Fuel tank cap for Hero Splendor and Passion bikes. OEM range: Rs 350-450.',
    ),
    Product(
      id: 'honda-drive-belt-activa',
      name: 'Drive Belt (V-Belt)',
      partNumber: 'HONDA-VBELT-ACT-DIO',
      brand: 'honda',
      category: 'engine',
      price: 400,
      stock: 210,
      image: 'https://picsum.photos/seed/honda-vbelt/400/400',
      images: ['https://picsum.photos/seed/honda-vbelt-2/400/400'],
      description:
          'Activa and Dio 110cc drive belt for high-volume scooter demand. OEM range: Rs 650-800.',
    ),
    Product(
      id: 'honda-clutch-rollers',
      name: 'Clutch Rollers (Set)',
      partNumber: 'HONDA-ROLLER-ACT-DIO',
      brand: 'honda',
      category: 'engine',
      price: 200,
      stock: 180,
      image: 'https://picsum.photos/seed/honda-rollers/400/400',
      images: ['https://picsum.photos/seed/honda-rollers-2/400/400'],
      description:
          'Clutch roller set for Honda Activa and Dio scooters. OEM range: Rs 350-450.',
    ),
    Product(
      id: 'honda-air-filter-viscous',
      name: 'Air Filter (Viscous)',
      partNumber: 'HONDA-AF-ACT-3G6G',
      brand: 'honda',
      category: 'engine',
      price: 200,
      stock: 240,
      image: 'https://picsum.photos/seed/honda-airfilter/400/400',
      images: ['https://picsum.photos/seed/honda-airfilter-2/400/400'],
      description:
          'Viscous air filter for Honda Activa 3G, 4G, 5G and 6G. OEM range: Rs 300-380.',
    ),
    Product(
      id: 'honda-front-nose-body',
      name: 'Front Nose (Body)',
      partNumber: 'HONDA-NOSE-ACT-3G4G',
      brand: 'honda',
      category: 'fiber',
      price: 550,
      stock: 85,
      image: 'https://picsum.photos/seed/honda-frontnose/400/400',
      images: ['https://picsum.photos/seed/honda-frontnose-2/400/400'],
      description:
          'Front nose body panel for Honda Activa 3G and 4G. OEM range: Rs 1,100-1,400.',
    ),
    Product(
      id: 'honda-brake-shoe-combi',
      name: 'Brake Shoe (Combi)',
      partNumber: 'HONDA-BS-ACT-DIO',
      brand: 'honda',
      category: 'braking',
      price: 250,
      stock: 210,
      image: 'https://picsum.photos/seed/honda-brakeshoe/400/400',
      images: ['https://picsum.photos/seed/honda-brakeshoe-2/400/400'],
      description:
          'Front and rear combi brake shoe for Honda Activa and Dio. OEM range: Rs 450-550.',
    ),
    Product(
      id: 'honda-starter-motor-self',
      name: 'Starter Motor (Self)',
      partNumber: 'HONDA-STM-ACT-SHN',
      brand: 'honda',
      category: 'electrical',
      price: 1050,
      stock: 60,
      image: 'https://picsum.photos/seed/honda-starter/400/400',
      images: ['https://picsum.photos/seed/honda-starter-2/400/400'],
      description:
          'Starter motor for Honda Activa 110 and Shine. OEM range: Rs 1,800-2,400.',
    ),
    Product(
      id: 'honda-mirror-set-pair',
      name: 'Mirror Set (Pair)',
      partNumber: 'HONDA-MIR-ACT-SHN',
      brand: 'honda',
      category: 'body',
      price: 215,
      stock: 190,
      image: 'https://picsum.photos/seed/honda-mirror/400/400',
      images: ['https://picsum.photos/seed/honda-mirror-2/400/400'],
      description:
          'Pair mirror set for Honda Activa and Shine. OEM range: Rs 350-450.',
    ),
    Product(
      id: 'honda-chain-sprocket-shine',
      name: 'Chain Sprocket Kit',
      partNumber: 'HONDA-CSK-CBSHINE125',
      brand: 'honda',
      category: 'engine',
      price: 775,
      stock: 95,
      image: 'https://picsum.photos/seed/honda-csk/400/400',
      images: ['https://picsum.photos/seed/honda-csk-2/400/400'],
      description:
          'Chain sprocket kit for Honda CB Shine 125. OEM range: Rs 1,200-1,400.',
    ),
    Product(
      id: 'honda-visor-headlight-cowl',
      name: 'Visor / Headlight Cowl',
      partNumber: 'HONDA-COWL-CBSHINE125',
      brand: 'honda',
      category: 'fiber',
      price: 400,
      stock: 80,
      image: 'https://picsum.photos/seed/honda-cowl/400/400',
      images: ['https://picsum.photos/seed/honda-cowl-2/400/400'],
      description:
          'Headlight cowl visor for Honda CB Shine 125. OEM range: Rs 800-1,100.',
    ),
    Product(
      id: 'bajaj-digital-speedometer',
      name: 'Digital Speedometer',
      partNumber: 'BAJAJ-SPD-P150-DIGI',
      brand: 'bajaj',
      category: 'electrical',
      price: 2000,
      stock: 45,
      image: 'https://picsum.photos/seed/bajaj-speedo/400/400',
      images: ['https://picsum.photos/seed/bajaj-speedo-2/400/400'],
      description:
          'Digital speedometer for Bajaj Pulsar 150. OEM range: Rs 3,200-4,000.',
    ),
    Product(
      id: 'bajaj-chain-sprocket-kit',
      name: 'Chain Sprocket Kit',
      partNumber: 'BAJAJ-CSK-P150',
      brand: 'bajaj',
      category: 'engine',
      price: 850,
      stock: 90,
      image: 'https://picsum.photos/seed/bajaj-csk/400/400',
      images: ['https://picsum.photos/seed/bajaj-csk-2/400/400'],
      description:
          'Chain sprocket kit for Bajaj Pulsar 150. OEM range: Rs 1,300-1,600.',
    ),
    Product(
      id: 'bajaj-disc-pad-front',
      name: 'Disc Pad (Front)',
      partNumber: 'BAJAJ-DPAD-PUL-AVG',
      brand: 'bajaj',
      category: 'braking',
      price: 150,
      stock: 180,
      image: 'https://picsum.photos/seed/bajaj-discpad/400/400',
      images: ['https://picsum.photos/seed/bajaj-discpad-2/400/400'],
      description:
          'Front disc pad for Bajaj Pulsar and Avenger models. OEM range: Rs 280-350.',
    ),
    Product(
      id: 'bajaj-clutch-cable',
      name: 'Clutch Cable',
      partNumber: 'BAJAJ-CC-P150180',
      brand: 'bajaj',
      category: 'engine',
      price: 135,
      stock: 160,
      image: 'https://picsum.photos/seed/bajaj-clutchcable/400/400',
      images: ['https://picsum.photos/seed/bajaj-clutchcable-2/400/400'],
      description:
          'Clutch cable for Bajaj Pulsar 150 and 180. OEM range: Rs 220-280.',
    ),
    Product(
      id: 'bajaj-tank-unit-fuel-gauge',
      name: 'Tank Unit (Fuel Gauge)',
      partNumber: 'BAJAJ-FUEL-PUL-PLT',
      brand: 'bajaj',
      category: 'electrical',
      price: 300,
      stock: 100,
      image: 'https://picsum.photos/seed/bajaj-fuelgauge/400/400',
      images: ['https://picsum.photos/seed/bajaj-fuelgauge-2/400/400'],
      description:
          'Fuel gauge tank unit for Bajaj Pulsar and Platina. OEM range: Rs 550-700.',
    ),
    Product(
      id: 'bajaj-headlight-assembly',
      name: 'Headlight Assembly',
      partNumber: 'BAJAJ-HL-P150-WOLF',
      brand: 'bajaj',
      category: 'electrical',
      price: 975,
      stock: 70,
      image: 'https://picsum.photos/seed/bajaj-headlight/400/400',
      images: ['https://picsum.photos/seed/bajaj-headlight-2/400/400'],
      description:
          'Wolf-eye headlight assembly for Bajaj Pulsar 150. OEM range: Rs 1,800-2,200.',
    ),
    Product(
      id: 'bajaj-block-piston-kit',
      name: 'Block Piston Kit',
      partNumber: 'BAJAJ-BPK-P150',
      brand: 'bajaj',
      category: 'engine',
      price: 2500,
      stock: 30,
      image: 'https://picsum.photos/seed/bajaj-piston/400/400',
      images: ['https://picsum.photos/seed/bajaj-piston-2/400/400'],
      description:
          'Block piston kit for Bajaj Pulsar 150 rebuild jobs. OEM range: Rs 4,500-5,500.',
    ),
    Product(
      id: 'bajaj-silencer-assembly',
      name: 'Silencer Assembly',
      partNumber: 'BAJAJ-SIL-PLT-CT100',
      brand: 'bajaj',
      category: 'engine',
      price: 2000,
      stock: 40,
      image: 'https://picsum.photos/seed/bajaj-silencer/400/400',
      images: ['https://picsum.photos/seed/bajaj-silencer-2/400/400'],
      description:
          'Silencer assembly for Bajaj Platina and CT100. OEM range: Rs 3,500-4,500.',
    ),
    Product(
      id: 'tvs-drive-belt-jupiter',
      name: 'Drive Belt',
      partNumber: 'TVS-VBELT-JUP-WEGO',
      brand: 'tvs',
      category: 'engine',
      price: 475,
      stock: 130,
      image: 'https://picsum.photos/seed/tvs-belt/400/400',
      images: ['https://picsum.photos/seed/tvs-belt-2/400/400'],
      description:
          'Drive belt for TVS Jupiter and Wego scooters. OEM range: Rs 750-900.',
    ),
    Product(
      id: 'tvs-chain-sprocket-apache',
      name: 'Chain Sprocket Kit',
      partNumber: 'TVS-CSK-APACHE160',
      brand: 'tvs',
      category: 'engine',
      price: 975,
      stock: 70,
      image: 'https://picsum.photos/seed/tvs-csk/400/400',
      images: ['https://picsum.photos/seed/tvs-csk-2/400/400'],
      description:
          'Chain sprocket kit for TVS Apache RTR 160. OEM range: Rs 1,400-1,800.',
    ),
    Product(
      id: 'tvs-brake-lever-right',
      name: 'Brake Lever (Right)',
      partNumber: 'TVS-BRL-APACHE-DISC',
      brand: 'tvs',
      category: 'braking',
      price: 150,
      stock: 140,
      image: 'https://picsum.photos/seed/tvs-brakelever/400/400',
      images: ['https://picsum.photos/seed/tvs-brakelever-2/400/400'],
      description:
          'Right side brake lever for TVS Apache disc models. OEM range: Rs 250-350.',
    ),
    Product(
      id: 'tvs-front-mudguard',
      name: 'Front Mudguard',
      partNumber: 'TVS-MUD-APACHE',
      brand: 'tvs',
      category: 'fiber',
      price: 625,
      stock: 65,
      image: 'https://picsum.photos/seed/tvs-mudguard/400/400',
      images: ['https://picsum.photos/seed/tvs-mudguard-2/400/400'],
      description:
          'Front mudguard for TVS Apache RTR series. OEM range: Rs 1,200-1,500.',
    ),
    Product(
      id: 'tvs-headlight-assembly-jupiter',
      name: 'Headlight Assembly',
      partNumber: 'TVS-HL-JUPITER',
      brand: 'tvs',
      category: 'electrical',
      price: 900,
      stock: 60,
      image: 'https://picsum.photos/seed/tvs-headlight/400/400',
      images: ['https://picsum.photos/seed/tvs-headlight-2/400/400'],
      description:
          'Headlight assembly for TVS Jupiter scooter. OEM range: Rs 1,600-1,900.',
    ),
    Product(
      id: 'tvs-self-start-relay',
      name: 'Self Start Relay',
      partNumber: 'TVS-SSR-XL100-JUP',
      brand: 'tvs',
      category: 'electrical',
      price: 215,
      stock: 120,
      image: 'https://picsum.photos/seed/tvs-relay/400/400',
      images: ['https://picsum.photos/seed/tvs-relay-2/400/400'],
      description:
          'Self start relay for TVS XL100 and Jupiter. OEM range: Rs 400-550.',
    ),
    Product(
      id: 'tvs-clutch-shoe-assembly',
      name: 'Clutch Shoe Assembly',
      partNumber: 'TVS-CSA-XL100-HD',
      brand: 'tvs',
      category: 'engine',
      price: 725,
      stock: 55,
      image: 'https://picsum.photos/seed/tvs-clutchshoe/400/400',
      images: ['https://picsum.photos/seed/tvs-clutchshoe-2/400/400'],
      description:
          'Clutch shoe assembly for TVS XL100 Heavy Duty. OEM range: Rs 1,200-1,500.',
    ),
    Product(
      id: 're-chain-sprocket-kit',
      name: 'Chain Sprocket Kit',
      partNumber: 'RE-CSK-350',
      brand: 'royal_enfield',
      category: 'engine',
      price: 1250,
      stock: 50,
      image: 'https://picsum.photos/seed/re-csk/400/400',
      images: ['https://picsum.photos/seed/re-csk-2/400/400'],
      description:
          'Chain sprocket kit for Royal Enfield Classic 350 and Bullet 350. OEM range: Rs 1,900-2,400.',
    ),
    Product(
      id: 're-clutch-plate-set',
      name: 'Clutch Plate Set',
      partNumber: 'RE-CLT-CLASSIC350',
      brand: 'royal_enfield',
      category: 'engine',
      price: 950,
      stock: 65,
      image: 'https://picsum.photos/seed/re-clutch/400/400',
      images: ['https://picsum.photos/seed/re-clutch-2/400/400'],
      description:
          'Clutch plate set for Royal Enfield Classic 350. OEM range: Rs 1,800-2,200.',
    ),
    Product(
      id: 're-oil-filter-uce',
      name: 'Oil Filter',
      partNumber: 'RE-OIL-UCE',
      brand: 'royal_enfield',
      category: 'lubricants',
      price: 75,
      stock: 200,
      image: 'https://picsum.photos/seed/re-oilfilter/400/400',
      images: ['https://picsum.photos/seed/re-oilfilter-2/400/400'],
      description:
          'Oil filter for all Royal Enfield UCE models. OEM range: Rs 110-150.',
    ),
    Product(
      id: 're-rear-view-mirrors',
      name: 'Rear View Mirrors (Chrome Pair)',
      partNumber: 'RE-MIR-CHROME-PAIR',
      brand: 'royal_enfield',
      category: 'body',
      price: 450,
      stock: 80,
      image: 'https://picsum.photos/seed/re-mirror/400/400',
      images: ['https://picsum.photos/seed/re-mirror-2/400/400'],
      description:
          'Chrome rear view mirror pair for Royal Enfield classic styling. OEM range: Rs 800-1,100.',
    ),
    Product(
      id: 're-silencer-indori-punjab',
      name: 'Silencer (Indori/Punjab)',
      partNumber: 'RE-SIL-CUSTOM-IND',
      brand: 'royal_enfield',
      category: 'engine',
      price: 2000,
      stock: 35,
      image: 'https://picsum.photos/seed/re-silencer/400/400',
      images: ['https://picsum.photos/seed/re-silencer-2/400/400'],
      description:
          'Custom aftermarket silencer for Royal Enfield riders. Stock OEM equivalent usually starts above Rs 4,000.',
    ),
    Product(
      id: 're-leg-guard-crash-guard',
      name: 'Leg Guard (Crash Guard)',
      partNumber: 'RE-LG-AIRFLY-BFLY',
      brand: 'royal_enfield',
      category: 'body',
      price: 1000,
      stock: 45,
      image: 'https://picsum.photos/seed/re-legguard/400/400',
      images: ['https://picsum.photos/seed/re-legguard-2/400/400'],
      description:
          'Heavy leg guard for Royal Enfield Classic and Bullet. OEM range: Rs 2,500-3,500.',
    ),
    Product(
      id: 're-control-cables-kit',
      name: 'Control Cables Kit',
      partNumber: 'RE-CABLE-ACC-CLT-BRK',
      brand: 'royal_enfield',
      category: 'engine',
      price: 425,
      stock: 75,
      image: 'https://picsum.photos/seed/re-cablekit/400/400',
      images: ['https://picsum.photos/seed/re-cablekit-2/400/400'],
      description:
          'Control cable kit with accelerator, clutch, brake and decompressor lines. OEM range: Rs 800-1,000.',
    ),
    Product(
      id: 'universal-horns-pair',
      name: 'Horns (Pair)',
      partNumber: 'UNI-HORN-12V-PAIR',
      brand: 'universal',
      category: 'electrical',
      price: 299,
      stock: 300,
      image: 'https://picsum.photos/seed/universal-horn/400/400',
      images: ['https://picsum.photos/seed/universal-horn-2/400/400'],
      description:
          '12V universal horn pair suitable for most bikes with minor adjustment. Fast-moving utility item with low margin.',
    ),
    Product(
      id: 'universal-led-fog-lights',
      name: 'LED Fog Lights',
      partNumber: 'UNI-FOG-OWL-6LED',
      brand: 'universal',
      category: 'electrical',
      price: 899,
      stock: 140,
      image: 'https://picsum.photos/seed/universal-fog/400/400',
      images: ['https://picsum.photos/seed/universal-fog-2/400/400'],
      description:
          'Owl eye and 6-LED bar style fog lights for bikes and scooters. Priced as a high-margin accessory placeholder.',
    ),
    Product(
      id: 'universal-mobile-holder',
      name: 'Mobile Holder',
      partNumber: 'UNI-MOB-CLAW-WP',
      brand: 'universal',
      category: 'body',
      price: 399,
      stock: 170,
      image: 'https://picsum.photos/seed/universal-holder/400/400',
      images: ['https://picsum.photos/seed/universal-holder-2/400/400'],
      description:
          'Universal mobile holder in claw grip and waterproof pouch styles. Fits most handlebar sizes.',
    ),
    Product(
      id: 'universal-engine-oil',
      name: 'Engine Oil 10W30 / 20W40 / 15W50',
      partNumber: 'UNI-OIL-MULTIGRADE-1L',
      brand: 'universal',
      category: 'lubricants',
      price: 499,
      stock: 260,
      image: 'https://picsum.photos/seed/universal-oil/400/400',
      images: ['https://picsum.photos/seed/universal-oil-2/400/400'],
      description:
          'Popular motorcycle engine oil grades from Motul and Castrol type inventory. Placeholder shelf price for user display.',
    ),
    Product(
      id: 'universal-seat-cover',
      name: 'Seat Cover',
      partNumber: 'UNI-SEAT-MESH-REX',
      brand: 'universal',
      category: 'body',
      price: 349,
      stock: 180,
      image: 'https://picsum.photos/seed/universal-seat/400/400',
      images: ['https://picsum.photos/seed/universal-seat-2/400/400'],
      description:
          'Universal mesh and rexine seat covers for common bike seat sizes. Mid-margin accessory.',
    ),
    Product(
      id: 'universal-disc-brake-fluid',
      name: 'Disc Brake Fluid DOT 3 / DOT 4',
      partNumber: 'UNI-BFLUID-DOT34',
      brand: 'universal',
      category: 'braking',
      price: 180,
      stock: 190,
      image: 'https://picsum.photos/seed/universal-brakefluid/400/400',
      images: ['https://picsum.photos/seed/universal-brakefluid-2/400/400'],
      description:
          '250ml disc brake fluid bottle for universal workshop use. Good supporting line item for service orders.',
    ),
  ];

  static const List<PromoBanner> banners = [
    PromoBanner(
      id: '1',
      title: 'Fast-Moving Bike Parts',
      subtitle: 'Hero, Honda, Bajaj, TVS and Royal Enfield essentials',
      image: 'https://picsum.photos/seed/moto_banner_1/900/500',
      gradient: AppColors.bannerBlue,
    ),
    PromoBanner(
      id: '2',
      title: 'Bulk Order Discounts',
      subtitle: 'Stock daily demand parts and improve retailer margins',
      image: 'https://picsum.photos/seed/moto_banner_2/900/500',
      gradient: AppColors.bannerSlate,
    ),
    PromoBanner(
      id: '3',
      title: 'Universal Accessories',
      subtitle: 'Keep horns, fog lights, oil and holders ready to move',
      image: 'https://picsum.photos/seed/moto_banner_3/900/500',
      gradient: AppColors.bannerEmerald,
    ),
  ];

  static List<AppNotification> notifications = [
    const AppNotification(
      id: 'n1',
      title: 'Hero Line Updated',
      message: 'High-demand Hero parts have been added to the storefront.',
      time: '2 hours ago',
      read: false,
      type: NoticeType.approved,
    ),
    const AppNotification(
      id: 'n2',
      title: 'Honda Scooter Demand',
      message: 'Activa and Dio service parts are now featured in the catalog.',
      time: '5 hours ago',
      read: true,
      type: NoticeType.info,
    ),
    const AppNotification(
      id: 'n3',
      title: 'Universal Accessories',
      message:
          'LED fog lights and mobile holders are now listed for quick orders.',
      time: '1 day ago',
      read: false,
      type: NoticeType.discount,
    ),
  ];

  static const List<AppOrder> orders = [
    AppOrder(
      id: '1023',
      date: '2026-03-10',
      status: 'Approved',
      total: 4200,
      items: [
        OrderItem(
          productId: 'hero-chain-sprocket-kit',
          name: 'Chain Sprocket Kit',
          quantity: 7,
          price: 600,
        ),
      ],
    ),
    AppOrder(
      id: '1022',
      date: '2026-03-08',
      status: 'Delivered',
      total: 4500,
      items: [
        OrderItem(
          productId: 're-clutch-plate-set',
          name: 'Clutch Plate Set',
          quantity: 5,
          price: 900,
        ),
      ],
    ),
    AppOrder(
      id: '1021',
      date: '2026-03-05',
      status: 'Shipped',
      total: 4990,
      items: [
        OrderItem(
          productId: 'universal-engine-oil',
          name: 'Engine Oil 10W30 / 20W40 / 15W50',
          quantity: 10,
          price: 499,
        ),
      ],
    ),
  ];

  static const UserInfo defaultUser = UserInfo(
    name: 'John Doe',
    shopName: 'Doe Auto Spares',
    email: 'john@doeautospares.com',
    phone: '+91 9876543210',
    address: '123, Main Road, Auto Market, New Delhi - 110001',
    status: 'Approved',
  );

  static String brandName(String brandId) {
    return brands
        .firstWhere((b) => b.id == brandId, orElse: () => brands.first)
        .name;
  }

  static String categoryName(String categoryId) {
    return categories
        .firstWhere((c) => c.id == categoryId, orElse: () => categories.first)
        .name;
  }
}
