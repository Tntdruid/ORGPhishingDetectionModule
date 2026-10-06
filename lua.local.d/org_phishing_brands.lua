return {

  YOUSEE = {
    symbol = "ORG_PHISHING_YOUSEE",
    score = 8.0,
    keywords = {
      "yousee",
      "you see",
      "you-see",
    },
    domains = {
      "yousee.dk",
      "yousee.tv",
      "yousee.mail",
      "klik.yousee.dk",
      "email.yousee.dk",
    },
  },

  POSTNORD = {
    symbol = "ORG_PHISHING_POSTNORD",
    score = 8.0,
    keywords = {
      "postnord",
      "post nord",
    },
    domains = {
      "postnord.dk",
      "postnord.com",
      "trk.postnord.com",
      "m.postnord.com",
    },
    carrier_notification = true,
  },

  COOP = {
    symbol = "ORG_PHISHING_COOP",
    score = 6.0,
    keywords = {
      "coop",
      "superbrugsen",
      "kvickly",
      "irma",
    },
    domains = {
      "coop.dk",
      "brugsen.dk",
      "kvickly.dk",
      "irma.dk",
      "email.coop.dk",
      "trk.coop.dk",
      "info.coop.dk",
    },
    trusted_mention_senders = {
      "advisering.e-boks.dk",
    },
  },

  NETFLIX = {
    symbol = "ORG_PHISHING_NETFLIX",
    score = 8.0,
    keywords = {
      "netflix",
    },
    domains = {
      "netflix.com",
      "email.netflix.com",
      "m.netflix.com",
    },
  },

  OPENAI = {
    symbol = "ORG_PHISHING_OPENAI",
    score = 9.0,
    keywords = {
      "openai",
      "chatgpt",
      "chat gpt",
      "gpt billing",
    },
    domains = {
      "openai.com",
      "chatgpt.com",
      "platform.openai.com",
    },
  },

  CLOUDSERVICES = {
    symbol = "ORG_PHISHING_CLOUDSERVICES",
    score = 8.0,
    keywords = {
      "cloud services",
      "cloud storage",
      "storage plan",
      "storage access",
      "subscription expired",
      "renew subscription",
      "cloud plan",
    },
    context_keywords = {
      "cloud storage is full",
      "cloud storage quota exceeded",
      "cloud account locked",
      "cloud account suspended",
      "cloud services subscription expired",
      "cloud storage subscription expired",
      "renew your cloud storage subscription",
      "verify your cloud account",
      "payment for cloud storage failed",
      "update your payment method to keep your cloud storage",
      "your cloud files will be deleted",
      "access to your cloud files has been suspended",
      "din cloud konto er låst",
      "din skylagring er fuld",
      "abonnement på skylagring er udløbet",
    },
    domains = {
      "cloudservices.com",
      "cloud-services.com",
    },
    url_requires_context = true,
  },

  APPLE = {
    symbol = "ORG_PHISHING_APPLE",
    score = 8.0,
    keywords = {
      "apple",
      "appie",
      "apple id",
      "icloud",
    },
    context_keywords = {
      "apple id has been locked",
      "apple id is locked",
      "apple id locked",
      "apple id suspended",
      "apple id disabled",
      "verify your apple id",
      "verify apple id",
      "confirm your apple id",
      "reset your apple id password",
      "unusual activity on your apple id",
      "icloud account locked",
      "icloud account suspended",
      "dit apple id er låst",
      "apple-id er låst",
      "bekræft dit apple id",
      "bekræft apple id",
      "unormal aktivitet på dit apple id",
      "din icloud-konto er låst",
    },
    domains = {
      "apple.com",
      "icloud.com",
      "appleid.apple.com",
      "idmsa.apple.com",
    },
    trusted_senders = {
      "postnord.com",
    },
  },

  TV2PLAY = {
    symbol = "ORG_PHISHING_TV2PLAY",
    score = 8.0,
    keywords = {
      "tv2",
      "tv 2",
      "tv2 play",
      "tv2play",
      "tv 2 play",
    },
    spoof_keywords = {
      "tv2 play",
      "tv2play",
      "tv 2 play",
    },
    domains = {
      "tv2.dk",
      "play.tv2.dk",
      "tv2play.dk",
    },
    trusted_mention_senders = {
      "tv2kosmopol.dk",
    },
  },

  JYSKEBANK = {
    symbol = "ORG_PHISHING_JYSKEBANK",
    score = 9.0,
    keywords = {
      "jyske bank",
      "jyskebank",
    },
    domains = {
      "jyskebank.dk",
      "jyskebank.com",
    },
  },

  SYDBANK = {
    symbol = "ORG_PHISHING_SYDBANK",
    score = 9.0,
    keywords = {
      "sydbank",
      "sydbank bank",
    },
    domains = {
      "sydbank.dk",
    },
  },

  LUNAR = {
    symbol = "ORG_PHISHING_LUNAR",
    score = 9.0,
    keywords = {
      "lunar",
      "lunar bank",
    },
    domains = {
      "lunar.app",
      "lunar.com",
    },
  },

  TRYG = {
    symbol = "ORG_PHISHING_TRYG",
    score = 8.0,
    keywords = {
      "tryg",
      "tryg forsikring",
    },
    domains = {
      "tryg.dk",
    },
  },

  TOPDANMARK = {
    symbol = "ORG_PHISHING_TOPDANMARK",
    score = 8.0,
    keywords = {
      "topdanmark",
      "top danmark",
    },
    domains = {
      "topdanmark.dk",
    },
  },

  ALMBRAND = {
    symbol = "ORG_PHISHING_ALMBRAND",
    score = 8.0,
    keywords = {
      "alm. brand",
      "alm brand",
      "almbrand",
    },
    domains = {
      "almbrand.dk",
    },
  },

  DSB = {
    symbol = "ORG_PHISHING_DSB",
    score = 8.0,
    keywords = {
      "dsb",
      "dsb billet",
    },
    domains = {
      "dsb.dk",
    },
  },

  REJSEKORT = {
    symbol = "ORG_PHISHING_REJSEKORT",
    score = 8.0,
    keywords = {
      "rejsekort",
      "rejse kort",
    },
    domains = {
      "rejsekort.dk",
    },
  },

  MATAS = {
    symbol = "ORG_PHISHING_MATAS",
    score = 8.0,
    keywords = {
      "matas",
      "matas kundeklub",
    },
    domains = {
      "matas.dk",
    },
  },

  NETTO = {
    symbol = "ORG_PHISHING_NETTO",
    score = 8.0,
    keywords = {
      "netto",
      "netto tilbud",
    },
    domains = {
      "netto.dk",
    },
  },

  REMA1000 = {
    symbol = "ORG_PHISHING_REMA1000",
    score = 8.0,
    keywords = {
      "rema 1000",
      "rema1000",
    },
    domains = {
      "rema1000.dk",
    },
  },

  OK = {
    symbol = "ORG_PHISHING_OK",
    score = 8.0,
    keywords = {
      "ok a.m.b.a.",
      "ok energi",
      "ok benzin",
    },
    domains = {
      "ok.dk",
    },
  },

  CLEVER = {
    symbol = "ORG_PHISHING_CLEVER",
    score = 8.0,
    keywords = {
      "clever",
      "clever ladestander",
      "clever abonnement",
    },
    domains = {
      "clever.dk",
    },
  },

  MOBILEPAY = {
    symbol = "ORG_PHISHING_MobilePay",
    score = 9.0,
    keywords = {
      "mobilepay",
    },
    domains = {
      "mobilepay.dk",
      "trk.mobilepay.dk",
      "email.mobilepay.dk",
    },
  },

  MITID = {
    symbol = "ORG_PHISHING_MITID",
    score = 9.0,
    keywords = {
      "mitid",
      "mit id",
      "mitld",
      "nemid",
      "nem id",
    },
    domains = {
      "mitid.dk",
      "www.mitid.dk",
      "nemid.dk",
    },
    trusted_mention_senders = {
      "yousee.dk",
      "e.telenor.dk",
    },
  },

  EBOKS = {
    symbol = "ORG_PHISHING_EBOKS",
    score = 9.0,
    keywords = {
      "e-boks",
      "eboks",
      "e boks",
    },
    domains = {
      "e-boks.dk",
      "e-boks.com",
      "eboks.dk",
      "eboks.com",
    },
  },

  DIGITALPOST = {
    symbol = "ORG_PHISHING_DIGITALPOST",
    score = 9.0,
    keywords = {
      "digital post",
      "digitalpost",
    },
    domains = {
      "digitalpost.dk",
    },
  },

  DANSKEBANK = {
    symbol = "ORG_PHISHING_DANSKEBANK",
    score = 9.0,
    keywords = {
      "danske bank",
      "danskebank",
    },
    domains = {
      "danskebank.dk",
      "danskebank.com",
    },
  },

  NORDEA = {
    symbol = "ORG_PHISHING_NORDEA",
    score = 9.0,
    keywords = {
      "nordea",
      "nordea bank",
    },
    domains = {
      "nordea.dk",
      "nordea.com",
    },
  },

  NETS = {
    symbol = "ORG_PHISHING_NETS",
    score = 9.0,
    keywords = {
      "nets",
      "nets betaling",
      "betalingsservice",
    },
    context_keywords = {
      "verify your nets account",
      "nets account locked",
      "nets card blocked",
      "nets payment failed",
      "nets password reset",
      "update your nets payment details",
      "bekræft dine betalingsoplysninger til nets",
      "nets-kontoen er spærret",
      "betalingsservice konto låst",
    },
    domains = {
      "nets.eu",
      "nets.dk",
      "betalingsservice.dk",
    },
    url_requires_context = true,
  },

  PAYPAL = {
    symbol = "ORG_PHISHING_PAYPAL",
    score = 9.0,
    keywords = {
      "paypal",
      "pay pal",
    },
    domains = {
      "paypal.com",
      "paypal.dk",
      "paypal.me",
    },
  },

  EASYPARK = {
    symbol = "ORG_PHISHING_EASYPARK",
    score = 8.0,
    keywords = {
      "easypark",
      "easy park",
      "easy-park",
    },
    domains = {
      "easypark.dk",
      "easypark.se",
      "easypark.no",
      "easypark.fi",
      "easypark.net",
    },
  },

  BROBIZZ = {
    symbol = "ORG_PHISHING_BROBIZZ",
    score = 8.0,
    keywords = {
      "brobizz",
      "bro bizz",
    },
    domains = {
      "brobizz.dk",
      "brobizz.com",
    },
  },

  KLARNA = {
    symbol = "ORG_PHISHING_KLARNA",
    score = 9.0,
    keywords = {
      "klarna",
      "klarna betaling",
      "klarna pay",
      "klarna invoice",
      "klarna faktura",
      "klarna konto",
      "&kappa;iarոɑ",
      "Κiarոɑ",
    },
    domains = {
      "klarna.com",
      "klarna.dk",
      "klarna.se",
      "klarna.no",
      "klarna.fi",
      "klarna.de",
      "klarna.co.uk",
      "email.klarna.com",
      "m.klarna.com",
      "klarna.mkt-mail.com",
    },
  },

  DAO = {
    symbol = "ORG_PHISHING_DAO",
    score = 8.0,
    keywords = {
      "dao",
      "dao365",
      "dao 365",
      "dao levering",
      "dao forsendelse",
      "dao tracking",
    },
    domains = {
      "dao.as",
      "dao365.dk",
      "email.dao.as",
      "trk.dao.as",
      "m.dao.as",
    },
    carrier_notification = true,
  },

  BURD = {
    symbol = "ORG_PHISHING_BURD",
    score = 8.0,
    keywords = {
      "burd",
      "burd delivery",
    },
    domains = {
      "burd.dk",
    },
    carrier_notification = true,
  },

  GLS = {
    symbol = "ORG_PHISHING_GLS",
    score = 8.0,
    keywords = {
      "gls",
      "gls pakke",
      "gls levering",
      "gls forsendelse",
      "gls tracking",
    },
    domains = {
      "gls.dk",
      "gls-group.eu",
      "gls.de",
      "gls.nl",
      "gls.at",
      "gls.it",
      "email.gls.dk",
      "trk.gls.dk",
      "m.gls.dk",
      "em3170.pakkeshop.dk",
      "pakkeshop.dk",
      "em4341.gls-denmark.com",
      "o1.email.gls.dk",
      "gls-denmark.com",
      "gls-denmark.dk",
    },
    carrier_notification = true,
  },

  DHL = {
    symbol = "ORG_PHISHING_DHL",
    score = 8.5,
    keywords = {
      "dhl",
      "dhl express",
      "dhl pakke",
      "dhl tracking",
    },
    domains = {
      "dhl.com",
      "dhl.de",
      "dhl.dk",
      "dhl.se",
      "dhl.fi",
      "dhl.no",
      "email.dhl.com",
      "trk.dhl.com",
      "m.dhl.com",
    },
    carrier_notification = true,
  },

  FEDEX = {
    symbol = "ORG_PHISHING_FEDEX",
    score = 8.0,
    keywords = {
      "fedex",
      "fed ex",
      "fedex tracking",
      "fedex shipment",
    },
    domains = {
      "fedex.com",
      "fedex.com.cn",
      "fedex.com.au",
      "fedex.com.uk",
      "email.fedex.com",
      "trk.fedex.com",
      "m.fedex.com",
    },
    carrier_notification = true,
  },

  SAXOBANK = {
    symbol = "ORG_PHISHING_SAXOBANK",
    score = 9.0,
    keywords = {
      "saxo",
      "saxobank",
      "saxo bank",
      "saxotrader",
      "saxo trader",
      "saxo investor",
    },
    domains = {
      "saxobank.com",
      "saxobank.dk",
      "saxobank.se",
      "saxobank.ch",
      "saxobank.co.uk",
      "mail.saxobank.com",
      "m.saxobank.com",
    },
  },

  INTERACTIVEBROKERS = {
    symbol = "ORG_PHISHING_INTERACTIVEBROKERS",
    score = 9.0,
    keywords = {
      "interactive brokers",
      "interactivebrokers",
      "ibkr",
    },
    domains = {
      "interactivebrokers.com",
      "ibkr.com",
    },
  },

  ANDELENERGI = {
    symbol = "ORG_PHISHING_ANDELENERGI",
    score = 8.0,
    keywords = {
      "andelenergi",
    },
    domains = {
      "kundecenter.andelenergi.dk",
      "andelenergi.dk",
      "em6544.kundecenter.andelenergi.dk",
    },
  },

  ELGIGANTEN = {
    symbol = "ORG_PHISHING_ELGIGANTEN",
    score = 8.0,
    keywords = {
      "elgiganten",
      "el giganten",
      "el-giganten",
    },
    domains = {
      "elgiganten.dk",
      "email.elgiganten.dk",
      "kundeservice.elgiganten.dk",
    },
  },

  SKAT = {
    symbol = "ORG_PHISHING_SKAT",
    score = 8.0,
    keywords = {
      "skat",
      "skattestyrelsen",
      "tastselv",
      "tast selv",
    },
    domains = {
      "skat.dk",
      "tastselv.skat.dk",
      "logon.skat.dk",
    },
  },

  SYGEFORSIKRING = {
    symbol = "ORG_PHISHING_SYGEFORSIKRING",
    score = 8.0,
    keywords = {
      "sygeforsikring",
      "sygeforsikringen danmark",
      "sygeforsikringen 'danmark'",
    },
    domains = {
      "sygeforsikring.dk",
    },
  },

  BORGER = {
    symbol = "ORG_PHISHING_BORGER",
    score = 8.0,
    keywords = {
      "borger.dk",
      "borger dk",
    },
    domains = {
      "borger.dk",
    },
  },

  SUNDHED = {
    symbol = "ORG_PHISHING_SUNDHED",
    score = 8.0,
    keywords = {
      "sundhed.dk",
      "sundhed dk",
    },
    domains = {
      "sundhed.dk",
    },
  },

  UDBETALINGDANMARK = {
    symbol = "ORG_PHISHING_UDBETALINGDANMARK",
    score = 8.0,
    keywords = {
      "udbetaling danmark",
      "udbetalingdanmark",
    },
    domains = {
      "udbetalingdanmark.dk",
    },
  },

  TELENOR = {
    symbol = "ORG_PHISHING_TELENOR",
    score = 8.0,
    keywords = {
      "telenor",
    },
    domains = {
      "telenor.dk",
    },
  },

  TELIA = {
    symbol = "ORG_PHISHING_TELIA",
    score = 8.0,
    keywords = {
      "telia",
    },
    domains = {
      "telia.dk",
    },
  },

  CBB = {
    symbol = "ORG_PHISHING_CBB",
    score = 8.0,
    keywords = {
      "cbb",
      "cbb mobil",
      "mit cbb",
    },
    domains = {
      "cbb.dk",
    },
  },

  OISTER = {
    symbol = "ORG_PHISHING_OISTER",
    score = 8.0,
    keywords = {
      "oister",
      "oister mobil",
      "mit oister",
    },
    domains = {
      "oister.dk",
    },
  },

  THREE = {
    symbol = "ORG_PHISHING_THREE",
    score = 8.0,
    keywords = {
      "3 mobil",
    },
    domains = {
      "3.dk",
    },
  },

  NORLYS = {
    symbol = "ORG_PHISHING_NORLYS",
    score = 8.0,
    keywords = {
      "norlys",
    },
    domains = {
      "norlys.dk",
    },
  },

  EWII = {
    symbol = "ORG_PHISHING_EWII",
    score = 8.0,
    keywords = {
      "ewii",
      "ewii energi",
    },
    domains = {
      "ewii.dk",
    },
  },

  NRGI = {
    symbol = "ORG_PHISHING_NRGI",
    score = 8.0,
    keywords = {
      "nrgi",
      "nrgi energi",
    },
    domains = {
      "nrgi.dk",
    },
  },

  SALLINGGROUP = {
    symbol = "ORG_PHISHING_SALLINGGROUP",
    score = 8.0,
    keywords = {
      "salling group",
      "sallinggroup",
    },
    domains = {
      "sallinggroup.com",
    },
  },

  MENY = {
    symbol = "ORG_PHISHING_MENY",
    score = 8.0,
    keywords = {
      "meny",
    },
    domains = {
      "meny.dk",
    },
  },

  BILKA = {
    symbol = "ORG_PHISHING_BILKA",
    score = 8.0,
    keywords = {
      "bilka",
    },
    domains = {
      "bilka.dk",
    },
    trusted_mention_senders = {
      "tv2kosmopol.dk",
    },
  },

  FOTEX = {
    symbol = "ORG_PHISHING_FOTEX",
    score = 8.0,
    keywords = {
      "føtex",
      "fotex",
    },
    domains = {
      "foetex.dk",
    },
  },

  LIDL = {
    symbol = "ORG_PHISHING_LIDL",
    score = 8.0,
    keywords = {
      "lidl",
    },
    domains = {
      "lidl.dk",
    },
  },

  POWER = {
    symbol = "ORG_PHISHING_POWER",
    score = 8.0,
    keywords = {
      "power",
      "power.dk",
    },
    context_keywords = {
      "verify your power account",
      "power account locked",
      "power account suspended",
      "power password reset",
      "power payment failed",
      "power order on hold",
      "power gift card expired",
      "bekræft din power konto",
      "din power konto er låst",
      "power gavekort er udløbet",
    },
    domains = {
      "power.dk",
    },
    url_requires_context = true,
  },

  BAUHAUS = {
    symbol = "ORG_PHISHING_BAUHAUS",
    score = 8.0,
    keywords = {
      "bauhaus",
    },
    domains = {
      "bauhaus.dk",
    },
  },

  SILVAN = {
    symbol = "ORG_PHISHING_SILVAN",
    score = 8.0,
    keywords = {
      "silvan",
    },
    domains = {
      "silvan.dk",
    },
  },

  STARK = {
    symbol = "ORG_PHISHING_STARK",
    score = 8.0,
    keywords = {
      "stark",
    },
    domains = {
      "stark.dk",
    },
  },

  XL_BYG = {
    symbol = "ORG_PHISHING_XL_BYG",
    score = 8.0,
    keywords = {
      "xl-byg",
      "xl byg",
    },
    domains = {
      "xl-byg.dk",
    },
  },

  BYGMA = {
    symbol = "ORG_PHISHING_BYGMA",
    score = 8.0,
    keywords = {
      "bygma",
    },
    domains = {
      "bygma.dk",
    },
  },

  DAVIDSEN = {
    symbol = "ORG_PHISHING_DAVIDSEN",
    score = 8.0,
    keywords = {
      "davidsen",
    },
    domains = {
      "davidsen.dk",
    },
  },

  JEMOGFIX = {
    symbol = "ORG_PHISHING_JEMOGFIX",
    score = 8.0,
    keywords = {
      "jem & fix",
      "jem og fix",
      "jemfix",
      "jemogfix",
    },
    domains = {
      "jemogfix.dk",
    },
  },

  HARALDNYBORG = {
    symbol = "ORG_PHISHING_HARALDNYBORG",
    score = 8.0,
    keywords = {
      "harald nyborg",
      "harald-nyborg",
    },
    domains = {
      "harald-nyborg.dk",
    },
  },

  TEN4 = {
    symbol = "ORG_PHISHING_TEN4",
    score = 8.0,
    keywords = {
      "10-4",
      "10 4",
    },
    domains = {
      "10-4.dk",
    },
  },

  JOHANNESFOG = {
    symbol = "ORG_PHISHING_JOHANNESFOG",
    score = 8.0,
    keywords = {
      "johannes fog",
      "johannesfog",
    },
    domains = {
      "johannesfog.dk",
    },
  },

  NEMLIG = {
    symbol = "ORG_PHISHING_NEMLIG",
    score = 8.0,
    keywords = {
      "nemlig.com",
    },
    domains = {
      "nemlig.com",
    },
  },

  SPOTIFY = {
    symbol = "ORG_PHISHING_SPOTIFY",
    score = 8.0,
    keywords = {
      "spotify",
      "spotify premium",
    },
    domains = {
      "spotify.com",
    },
  },

  STEAM = {
    symbol = "ORG_PHISHING_STEAM",
    score = 8.0,
    keywords = {
      "steam",
      "steam guard",
      "steampowered",
    },
    context_keywords = {
      "verify your steam account",
      "steam account locked",
      "steam account suspended",
      "steam account disabled",
      "reset your steam password",
      "steam guard disabled",
      "unauthorized steam purchase",
      "steam wallet payment failed",
      "confirm your steam trade",
      "steam trade offer cancelled",
    },
    domains = {
      "steampowered.com",
      "steamcommunity.com",
    },
    url_requires_context = true,
  },

  BOOKING = {
    symbol = "ORG_PHISHING_BOOKING",
    score = 8.0,
    keywords = {
      "booking.com",
      "booking",
    },
    context_keywords = {
      "verify your booking.com account",
      "confirm your booking.com account",
      "booking.com account locked",
      "booking.com payment failed",
      "payment required by booking.com",
      "booking.com reservation cancelled",
      "booking.com password reset",
      "update payment method on booking.com",
      "bekræft din booking.com konto",
    },
    domains = {
      "booking.com",
    },
    url_requires_context = true,
  },

  VIAPLAY = {
    symbol = "ORG_PHISHING_VIAPLAY",
    score = 8.0,
    keywords = {
      "viaplay",
      "viaplay abonnement",
    },
    domains = {
      "viaplay.dk",
      "viaplay.com",
    },
  },

  UPS = {
    symbol = "ORG_PHISHING_UPS",
    score = 8.0,
    keywords = {
      "ups",
      "ups levering",
      "ups tracking",
    },
    context_keywords = {
      "delivery fee",
      "customs fee",
      "package held",
      "parcel held",
      "payment required for delivery",
      "pay the delivery fee",
      "pay customs fee",
      "verify your delivery address",
      "confirm your delivery address",
      "package will be returned",
      "parcel will be returned",
      "delivery payment failed",
      "leveringsgebyr",
      "pakken tilbageholdes",
      "bekræft din leveringsadresse",
      "pakken returneres",
    },
    domains = {
      "ups.com",
    },
    carrier_notification = true,
    url_requires_context = true,
  },

  ARBEJDERNESLANDSBANK = {
    symbol = "ORG_PHISHING_ARBEJDERNESLANDSBANK",
    score = 9.0,
    keywords = {
      "arbejdernes landsbank",
      "arbejderneslandsbank",
      "al-bank",
    },
    domains = {
      "al-bank.dk",
      "al-bank.com",
    },
  },

  NYKREDIT = {
    symbol = "ORG_PHISHING_NYKREDIT",
    score = 9.0,
    keywords = {
      "nykredit",
      "nykredit bank",
    },
    domains = {
      "nykredit.dk",
      "nykredit.com",
    },
    trusted_mention_senders = {
      "e-boks.dk",
    },
  },

  BRING = {
    symbol = "ORG_PHISHING_BRING",
    score = 9.0,
    keywords = {
      "bring",
      "bring pakke",
      "bring levering",
      "bring tracking",
      "bring shipment",
    },
    context_keywords = {
      "delivery fee",
      "customs fee",
      "package held",
      "parcel held",
      "payment required for delivery",
      "pay the delivery fee",
      "pay customs fee",
      "verify your delivery address",
      "confirm your delivery address",
      "package will be returned",
      "parcel will be returned",
      "delivery payment failed",
      "leveringsgebyr",
      "pakken tilbageholdes",
      "bekræft din leveringsadresse",
      "pakken returneres",
    },
    domains = {
      "bring.dk",
      "bring.no",
      "bring.se",
      "bring.fi",
    },
    carrier_notification = true,
    url_requires_context = true,
  },

  WOLT = {
    symbol = "ORG_PHISHING_WOLT",
    score = 8.0,
    keywords = {
      "wolt",
      "wolt market",
      "wolt+",
    },
    domains = {
      "wolt.com",
    },
  },
}
