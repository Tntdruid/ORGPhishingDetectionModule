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
    urgency = {
      "yousee betaling mangler",
      "yousee konto låst",
      "verify your yousee account",
      "update your yousee payment",
    }
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
    urgency = {
      "din postnord pakke er tilbageholdt",
      "postnord levering afventer betaling",
      "postnord pakke mangler information",
      "verify your postnord delivery",
    }
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
    urgency = {
      "din bonus er udløbet",
      "aktiver din bonus nu",
    }
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
    urgency = {
      "din netflix betaling er afvist",
      "netflix betaling mangler",
      "din netflix konto er låst",
      "netflix abonnement udløber",
      "update your netflix payment",
      "verify your netflix account",
    }
  },

  MOBILEPAY = {
    symbol = "ORG_PHISHING_MobilePay",
    score = 9.0,
    keywords = {
      "mobilepay",
      "mitid",
      "nemid",
    },
    domains = {
      "mobilepay.dk",
      "trk.mobilepay.dk",
      "email.mobilepay.dk",
    },
    urgency = {
      "din mobilepay er spærret",
      "bekræft din identitet",
    }
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
    urgency = {
      "ubetalt parkering",
      "ubetalt parkeringsafgift",
      "betaling for parkering mangler",
      "din parkering er ugyldig",
      "verify your easypark account",
    }
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
    urgency = {
      "din klarna betaling er afvist",
      "klarna betaling mangler",
      "din klarna faktura er udløbet",
      "verify your klarna account",
      "update your klarna payment",
      "klarna security update",
      "klarna konto låst",
    }
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
    urgency = {
      "din dao levering er tilbageholdt",
      "dao levering afventer betaling",
      "dao pakke mangler information",
      "verify your dao delivery",
      "dao security update",
      "dao konto låst",
    }
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
    urgency = {
      "din gls pakke er tilbageholdt",
      "gls levering afventer betaling",
      "gls pakke mangler information",
      "verify your gls delivery",
      "gls security update",
    }
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
    urgency = {
      "din dhl pakke er tilbageholdt",
      "dhl levering afventer betaling",
      "dhl shipment on hold",
      "verify your dhl delivery",
      "dhl security update",
    }
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
    urgency = {
      "your fedex package is on hold",
      "fedex shipment requires payment",
      "fedex delivery pending",
      "verify your fedex shipment",
      "fedex security update",
    }
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
    urgency = {
      "din saxobank konto er låst",
      "saxobank konto låst",
      "verify your saxobank account",
      "update your saxobank payment",
      "saxobank security update",
      "saxobank login issue",
      "saxobank payment issue",
    }
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
    urgency = {
      "Du risikerer at få lukket for strømmen",
    }
  },

  BRING = {
    symbol = "ORG_PHISHING_BRING",
    score = 8.0,
    keywords = {
      "bring",
      "bring pakke",
      "bring levering",
      "bring tracking",
      "bring shipment",
    },
    domains = {
      "bring.dk",
      "bring.no",
      "bring.se",
      "bring.fi",
    },
    urgency = {
      "Se hvornår den ankommer",
    }
  },
}
