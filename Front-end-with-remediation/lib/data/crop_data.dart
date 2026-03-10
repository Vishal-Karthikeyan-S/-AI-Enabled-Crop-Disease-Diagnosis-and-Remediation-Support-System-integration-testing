import '../models/crop_model.dart';

class CropData {
  static final List<CropModel> crops = [
    // Paddy
    CropModel(
      id: 'paddy',
      name: 'Paddy',
      category: 'paddy',
      nameTranslations: {
        'en': 'Paddy',
        'hi': 'धान',
        'te': 'వరి',
        'ta': 'நெல்',
      },
      careInstructions: {
        'en':
            'Paddy requires flooded fields. Maintain 2-4 inches of water. Apply fertilizer in 3 splits. Control weeds early.',
        'hi':
            'धान के लिए जलभर्ण खेत चाहिए। 2-4 इंच पानी बनाए रखें। 3 बार में खाद डालें।',
        'te': 'వరికి నీటితో నిండిన పొలాలు కావాలి। 2-4 అంగుళాల నీరు ఉంచండి।',
        'ta':
            'நெல்லுக்கு வெள்ளம் நிரப்பப்பட்ட வயல்கள் தேவை। 2-4 அங்குல நீரை பராமரிக்கவும்.',
      },
      waterRequirements: {
        'en':
            '1200-1500 mm total water. Keep field flooded throughout growing season.',
        'hi': '1200-1500 मिमी कुल पानी। पूरे मौसम में खेत को जलमग्न रखें।',
        'te':
            '1200-1500 మిమీ మొత్తం నీరు. వృద్ధి కాలం అంతా పొలాన్ని నీరుతో నింపండి.',
        'ta':
            '1200-1500 மிமீ மொத்த நீர். வளரும் காலம் முழுவதும் வயலை வெள்ளத்தில் வைக்கவும்.',
      },
      growthDuration: {
        'en': '120-150 days depending on variety',
        'hi': 'किस्म के आधार पर 120-150 दिन',
        'te': 'రకాన్ని బట్టి 120-150 రోజులు',
        'ta': 'வகையைப் பொறுத்து 120-150 நாட்கள்',
      },
      commonDiseases: {
        'en': [
          Disease(
            name: 'Blast Disease',
            description: 'Fungal disease causing lesions on leaves',
            symptoms: [
              'Diamond-shaped lesions',
              'Gray centers',
              'Brown margins'
            ],
            remedies: [
              'Apply Tricyclazole',
              'Use resistant varieties',
              'Avoid excess nitrogen'
            ],
          ),
          Disease(
            name: 'Bacterial Leaf Blight',
            description: 'Bacterial infection of leaves',
            symptoms: ['Water-soaked lesions', 'Yellow leaves', 'Wilting'],
            remedies: [
              'Spray Copper oxychloride',
              'Remove infected plants',
              'Use clean seeds'
            ],
          ),
        ],
        'hi': [
          Disease(
            name: 'ब्लास्ट रोग',
            description: 'पत्तियों पर घावों का कारण बनने वाला कवक रोग',
            symptoms: ['हीरे के आकार के घाव', 'भूरे केंद्र', 'भूरे किनारे'],
            remedies: [
              'ट्राइसाइक्लाज़ोल लगाएं',
              'प्रतिरोधी किस्मों का उपयोग करें'
            ],
          ),
          Disease(
            name: 'जीवाणु पर्ण झुलसा',
            description: 'पत्तियों का बैक्टीरियल संक्रमण',
            symptoms: ['पानी भिगोए घाव', 'पीली पत्तियां', 'मुरझाना'],
            remedies: [
              'कॉपर ऑक्सीक्लोराइड स्प्रे करें',
              'संक्रमित पौधों को हटाएं'
            ],
          ),
        ],
        'te': [
          Disease(
            name: 'బ్లాస్ట్ వ్యాధి',
            description: 'ఆకులపై గాయాలు కలిగించే శిలీంధ్ర వ్యాధి',
            symptoms: ['వజ్రాకార గాయాలు', 'బూడిద కేంద్రాలు'],
            remedies: ['ట్రైసైక్లాజోల్ వర్తించండి', 'నిరోధక రకాలు వాడండి'],
          ),
        ],
        'ta': [
          Disease(
            name: 'பிளாஸ்ட் நோய்',
            description: 'இலைகளில் காயங்களை ஏற்படுத்தும் பூஞ்சை நோய்',
            symptoms: ['வைர வடிவ காயங்கள்', 'சாம்பல் மையங்கள்'],
            remedies: ['டிரைசைக்லாசோல் பயன்படுத்தவும்'],
          ),
        ],
      },
    ),

    // Wheat
    CropModel(
      id: 'wheat',
      name: 'Wheat',
      category: 'wheat',
      nameTranslations: {
        'en': 'Wheat',
        'hi': 'गेहूं',
        'te': 'గోధుమ',
        'ta': 'கோதுமை',
      },
      careInstructions: {
        'en':
            'Sow at proper depth (4-5 cm). Apply irrigation at critical stages. Control weeds in early stage.',
        'hi':
            'उचित गहराई (4-5 सेमी) पर बोयें। महत्वपूर्ण चरणों में सिंचाई करें।',
        'te': 'సరైన లోతులో (4-5 సెం.మీ) విత్తండి। కీలక దశల్లో నీరు ఇవ్వండి.',
        'ta':
            'சரியான ஆழத்தில் (4-5 செ.மீ) விதைக்கவும். முக்கிய கட்டங்களில் நீர்ப்பாசனம்.',
      },
      waterRequirements: {
        'en':
            '450-650 mm. Critical: Crown root initiation, flowering, grain filling',
        'hi': '450-650 मिमी। महत्वपूर्ण चरण: जड़ विकास, फूल, अनाज भरना',
        'te': '450-650 మిమీ. కీలక దశలు: వేరు ప్రారంభం, పుష్పించు కాలం',
        'ta': '450-650 மிமீ. முக்கிய நிலைகள்: வேர் தோற்றம், மலர்தல்',
      },
      growthDuration: {
        'en': '120-140 days',
        'hi': '120-140 दिन',
        'te': '120-140 రోజులు',
        'ta': '120-140 நாட்கள்',
      },
      commonDiseases: {
        'en': [
          Disease(
            name: 'Rust',
            description: 'Fungal disease with rust-colored spores',
            symptoms: ['Orange-red pustules', 'Yellow leaves', 'Reduced yield'],
            remedies: [
              'Apply Propiconazole',
              'Use resistant varieties',
              'Timely sowing'
            ],
          ),
        ],
        'hi': [
          Disease(
            name: 'रतुआ',
            description: 'जंग रंग के बीजाणुओं वाला कवक रोग',
            symptoms: ['नारंगी-लाल फुंसी', 'पीली पत्तियां'],
            remedies: ['प्रोपिकोनाज़ोल लगाएं', 'प्रतिरोधी किस्में उपयोग करें'],
          ),
        ],
        'te': [
          Disease(
            name: 'తుప్పు',
            description: 'తుప్పు రంగు బీజాణువులతో శిలీంధ్ర వ్యాధి',
            symptoms: ['నారింజ-ఎరుపు గడ్డలు', 'పసుపు ఆకులు'],
            remedies: ['ప్రొపికొనజోల్ వర్తించండి'],
          ),
        ],
        'ta': [
          Disease(
            name: 'துரு',
            description: 'துரு நிற வித்துக்களுடன் பூஞ்சை நோய்',
            symptoms: ['ஆரஞ்சு-சிவப்பு கொப்புளங்கள்'],
            remedies: ['ப்ராபிகோனசோல் பயன்படுத்தவும்'],
          ),
        ],
      },
    ),

    // Vegetables - Tomato
    CropModel(
      id: 'tomato',
      name: 'Tomato',
      category: 'vegetables',
      subcategory: 'tomato',
      nameTranslations: {
        'en': 'Tomato',
        'hi': 'टमाटर',
        'te': 'టమోటా',
        'ta': 'தக்காளி',
      },
      careInstructions: {
        'en':
            'Stake plants for support. Prune suckers. Apply mulch to retain moisture.',
        'hi':
            'समर्थन के लिए दांव लगाएं। चूसने वालों को काटें। नमी बनाए रखने के लिए गीली घास डालें।',
        'te': 'మద్దతు కోసం కొయ్యలు పెట్టండి. చిగురులు కత్తిరించండి.',
        'ta': 'ஆதரவுக்காக தூண்கள் வைக்கவும். கிளைகளை கத்தரிக்கவும்.',
      },
      waterRequirements: {
        'en': 'Regular watering. 25-30 mm per week. Avoid waterlogging.',
        'hi': 'नियमित पानी देना। प्रति सप्ताह 25-30 मिमी। जलजमाव से बचें।',
        'te': 'క్రమం తప్పకుండా నీరు ఇవ్వండి. వారానికి 25-30 మిమీ.',
        'ta': 'வழக்கமான நீர்ப்பாசனம். வாரத்திற்கு 25-30 மிமீ.',
      },
      growthDuration: {
        'en': '60-80 days from transplanting',
        'hi': 'प्रत्यारोपण से 60-80 दिन',
        'te': 'మార్పిడి నుండి 60-80 రోజులు',
        'ta': 'நடவு செய்த பின் 60-80 நாட்கள்',
      },
      commonDiseases: {
        'en': [
          Disease(
            name: 'Late Blight',
            description: 'Devastating fungal disease',
            symptoms: ['Dark lesions on leaves', 'White mold', 'Fruit rot'],
            remedies: [
              'Apply Mancozeb',
              'Remove infected plants',
              'Improve air circulation'
            ],
          ),
        ],
        'hi': [
          Disease(
            name: 'झुलसा रोग',
            description: 'विनाशकारी कवक रोग',
            symptoms: ['पत्तियों पर काले धब्बे', 'सफेद फफूंद'],
            remedies: ['मैनकोज़ेब लगाएं', 'संक्रमित पौधों को हटाएं'],
          ),
        ],
        'te': [
          Disease(
            name: 'చివరి  బ్లైట్',
            description: 'విధ్వంసక శిలీంధ్ర వ్యాధి',
            symptoms: ['ఆకులపై నల్ల గాయాలు', 'తెల్ల అచ్చు'],
            remedies: ['మాంకోజెబ్ వర్తించండి'],
          ),
        ],
        'ta': [
          Disease(
            name: 'பிந்தைய பூச்சி',
            description: 'அழிவுகரமான பூஞ்சை நோய்',
            symptoms: ['இலைகளில் கரும் காயங்கள்'],
            remedies: ['மாங்கோசெப் பயன்படுத்தவும்'],
          ),
        ],
      },
    ),

    // Vegetables - Potato
    CropModel(
      id: 'potato',
      name: 'Potato',
      category: 'vegetables',
      subcategory: 'potato',
      nameTranslations: {
        'en': 'Potato',
        'hi': 'आलू',
        'te': 'బంగాళాదుంప',
        'ta': 'உருளைக்கிழங்கு',
      },
      careInstructions: {
        'en':
            'Earth up plants regularly. Ensure good drainage. Apply balanced fertilizer.',
        'hi': 'नियमित रूप से मिट्टी चढ़ाएं। अच्छी जल निकासी सुनिश्चित करें।',
        'te': 'క్రమం తప్పకుండా మట్టి పెట్టండి. మంచి డ్రైనేజీ ఉండేలా చూడండి.',
        'ta': 'தவறாமல் மண் போடவும். நல்ல வடிகால் உறுதிப்படுத்தவும்.',
      },
      waterRequirements: {
        'en': '500-700 mm total. Critical during tuber formation.',
        'hi': '500-700 मिमी कुल। कंद निर्माण के दौरान महत्वपूर्ण।',
        'te': '500-700 మిమీ మొత్తం. దినుసులు ఏర్పడునప్పుడు కీలకం.',
        'ta': '500-700 மிமீ மொத்தம். கிழங்கு உருவாக்கத்தின் போது முக்கியம்.',
      },
      growthDuration: {
        'en': '90-120 days',
        'hi': '90-120 दिन',
        'te': '90-120 రోజులు',
        'ta': '90-120 நாட்கள்',
      },
      commonDiseases: {
        'en': [
          Disease(
            name: 'Late Blight',
            description: 'Most serious potato disease',
            symptoms: [
              'Dark patches on leaves',
              'White growth underneath',
              'Tuber rot'
            ],
            remedies: [
              'Apply Copper fungicide',
              'Use certified seeds',
              'Destroy infected plants'
            ],
          ),
        ],
        'hi': [
          Disease(
            name: 'पछेती अंगमारी',
            description: 'सबसे गंभीर आलू रोग',
            symptoms: ['पत्तियों पर काले धब्बे', 'नीचे सफेद वृद्धि'],
            remedies: ['कॉपर कवकनाशी लगाएं', 'प्रमाणित बीज उपयोग करें'],
          ),
        ],
        'te': [
          Disease(
            name: 'చివరి బ్లైట్',
            description: 'అత్యంత తీవ్రమైన బంగాళాదుంప వ్యాధి',
            symptoms: ['ఆకులపై నల్ల మచ్చలు'],
            remedies: ['కాపర్ శిలీంధ్రనాశిని వర్తించండి'],
          ),
        ],
        'ta': [
          Disease(
            name: 'பிந்தைய வாட்டம்',
            description: 'மிக தீவிரமான உருளை நோய்',
            symptoms: ['இலைகளில் கரும் திட்டுகள்'],
            remedies: ['காப்பர் பூஞ்சைக்கொல்லி பயன்படுத்தவும்'],
          ),
        ],
      },
    ),

    // Fruits - Mango
    CropModel(
      id: 'mango',
      name: 'Mango',
      category: 'fruits',
      subcategory: 'mango',
      nameTranslations: {
        'en': 'Mango',
        'hi': 'आम',
        'te': 'మామిడి',
        'ta': 'மாம்பழம்',
      },
      careInstructions: {
        'en':
            'Prune dead branches. Apply organic manure annually. Protect from frost.',
        'hi': 'मृत शाखाओं की छंटाई करें। वार्षिक जैविक खाद डालें।',
        'te': 'చనిపోయిన కొమ్మలు కత్తిరించండి. ఏటా సేంద్రీయ ఎరువులు వేయండి.',
        'ta': 'இறந்த கிளைகளை வெட்டவும். ஆண்டுதோறும் இயற்கை உரம் இடவும்.',
      },
      waterRequirements: {
        'en':
            'Deep watering during fruit development. Reduce before flowering.',
        'hi': 'फल विकास के दौरान गहरी सिंचाई। फूल आने से पहले कम करें।',
        'te':
            'పండు అభివృద్ధి సమయంలో లోతైన నీరు. పుష్పించడానికి ముందు తగ్గించండి.',
        'ta': 'பழ வளர்ச்சியின் போது ஆழமான நீர். பூக்கும் முன் குறைக்கவும்.',
      },
      growthDuration: {
        'en': 'Fruits in 3-5 years after planting. Harvest season: May-July',
        'hi': 'रोपण के बाद 3-5 वर्षों में फल। फसल का मौसम: मई-जुलाई',
        'te': 'నాటిన తర్వాత 3-5 సంవత్సరాలలో ఫలాలు. కోత కాలం: మే-జూలై',
        'ta': 'நடவு செய்த பின் 3-5 ஆண்டுகளில் பழம். அறுவடை: மே-ஜூலை',
      },
      commonDiseases: {
        'en': [
          Disease(
            name: 'Anthracnose',
            description: 'Fungal disease affecting fruit',
            symptoms: ['Black spots on fruit', 'Fruit rot', 'Leaf spots'],
            remedies: [
              'Apply Carbendazim',
              'Remove infected fruits',
              'Ensure proper spacing'
            ],
          ),
        ],
        'hi': [
          Disease(
            name: 'एन्थ्रेक्नोज',
            description: 'फल को प्रभावित करने वाला कवक रोग',
            symptoms: ['फलों पर काले धब्बे', 'फल सड़ना'],
            remedies: ['कार्बेन्डाजिम लगाएं', 'संक्रमित फलों को हटाएं'],
          ),
        ],
        'te': [
          Disease(
            name: 'ఆంత్రాక్నోస్',
            description: 'పండ్లను ప్రభావితం చేసే శిలీంధ్ర వ్యాధి',
            symptoms: ['పండ్లపై నల్ల మచ్చలు'],
            remedies: ['కార్బెండాజిమ్ వర్తించండి'],
          ),
        ],
        'ta': [
          Disease(
            name: 'ஆந்த்ரக்னோஸ்',
            description: 'பழத்தை பாதிக்கும் பூஞ்சை நோய்',
            symptoms: ['பழத்தில் கரும் புள்ளிகள்'],
            remedies: ['கார்பெண்டசிம் பயன்படுத்தவும்'],
          ),
        ],
      },
    ),

    // Fruits - Banana
    CropModel(
      id: 'banana',
      name: 'Banana',
      category: 'fruits',
      subcategory: 'banana',
      nameTranslations: {
        'en': 'Banana',
        'hi': 'केला',
        'te': 'అరటి',
        'ta': 'வாழை',
      },
      careInstructions: {
        'en': 'Remove dead leaves. Provide wind protection. Mulch around base.',
        'hi': 'मृत पत्तियों को हटाएं। हवा से सुरक्षा प्रदान करें।',
        'te': 'చనిపోయిన ఆకులు తొలగించండి. గాలి రక్షణ ఇవ్వండి.',
        'ta': 'இறந்த இலைகளை அகற்றவும். காற்று பாதுகாப்பு அளிக்கவும்.',
      },
      waterRequirements: {
        'en': 'High water needs. 2000-2500 mm annually. Avoid waterlogging.',
        'hi': 'अधिक पानी की आवश्यकता। वार्षिक 2000-2500 मिमी।',
        'te': 'అధిక నీటి అవసరాలు. సంవత్సరానికి 2000-2500 మిమీ.',
        'ta': 'அதிக நீர் தேவை. ஆண்டுதோறும் 2000-2500 மிமீ.',
      },
      growthDuration: {
        'en': '9-12 months to harvest',
        'hi': 'फसल के लिए 9-12 महीने',
        'te': 'కోత వరకు 9-12 నెలలు',
        'ta': 'அறுவடைக்கு 9-12 மாதங்கள்',
      },
      commonDiseases: {
        'en': [
          Disease(
            name: 'Panama Disease',
            description: 'Soil-borne fungal disease',
            symptoms: ['Yellowing of leaves', 'Wilting', 'Plant death'],
            remedies: [
              'Use resistant varieties',
              'Soil solarization',
              'Crop rotation'
            ],
          ),
        ],
        'hi': [
          Disease(
            name: 'पनामा रोग',
            description: 'मिट्टी जनित कवक रोग',
            symptoms: ['पत्तियों का पीला होना', 'मुरझाना'],
            remedies: ['प्रतिरोधी किस्मों का उपयोग करें', 'मिट्टी सौरीकरण'],
          ),
        ],
        'te': [
          Disease(
            name: 'పనామా వ్యాధి',
            description: 'మట్టిలో ఉండే శిలీంధ్ర వ్యాధి',
            symptoms: ['ఆకుల పసుపు రంగు', 'వాడిపోవడం'],
            remedies: ['నిరోధక రకాలను వాడండి'],
          ),
        ],
        'ta': [
          Disease(
            name: 'பனாமா நோய்',
            description: 'மண்வழி பூஞ்சை நோய்',
            symptoms: ['இலைகள் மஞ்சளாதல்'],
            remedies: ['எதிர்ப்பு வகைகளை பயன்படுத்தவும்'],
          ),
        ],
      },
    ),
  ];

  static CropModel? getCropById(String id) {
    try {
      return crops.firstWhere((crop) => crop.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<CropModel> getCropsByCategory(String category) {
    return crops.where((crop) => crop.category == category).toList();
  }

  static List<CropModel> getCropsBySubcategory(String subcategory) {
    return crops.where((crop) => crop.subcategory == subcategory).toList();
  }
}
