class VehicleDatabase {
  static final VehicleDatabase _instance = VehicleDatabase._internal();
  factory VehicleDatabase() => _instance;
  VehicleDatabase._internal();

  // Tüm araç markalarının veritabanı
  final Map<String, Map<String, dynamic>> _vehicleData = {
    // TÜRK MARKALARI
    'togg': {
      'models': {
        'T10X': {
          'years': [2023, 2024],
          'engine_types': ['Electric'],
          'common_faults': ['B1001', 'B1002', 'B1003'],
          'maintenance_intervals': {
            'battery_check': 20000,
            'software_update': 10000,
            'brake_fluid': 40000,
          }
        }
      }
    },

    // ALMAN MARKALARI
    'bmw': {
      'models': {
        '3 Series': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['2.0i', '2.0d', '3.0i', '3.0d'],
          'common_faults': ['P0016', 'P0017', 'P0300', 'P0420', 'P11A0'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
            'brake_pads': 40000,
            'timing_chain': 150000,
          }
        },
        '5 Series': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['2.0d', '3.0d', '4.4i'],
          'common_faults': ['P0016', 'P0300', 'P0420', 'P0087'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
            'brake_pads': 45000,
          }
        },
        'X3': {
          'years': [2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['2.0d', '3.0d', '2.0i'],
          'common_faults': ['P0016', 'P0300', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        }
      }
    },

    'mercedes-benz': {
      'models': {
        'C-Class': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.6T', '2.0T', '2.1d', '3.0d'],
          'common_faults': ['P0016', 'P0017', 'P0300', 'P0420', 'P0087'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
            'brake_pads': 40000,
          }
        },
        'E-Class': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['2.0T', '3.0d', '3.5V6'],
          'common_faults': ['P0016', 'P0300', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        },
        'GLC': {
          'years': [2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['2.0T', '2.1d'],
          'common_faults': ['P0300', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        }
      }
    },

    'audi': {
      'models': {
        'A3': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.4T', '1.6T', '2.0T', '1.6TDI', '2.0TDI'],
          'common_faults': ['P0016', 'P0300', 'P0420', 'P2015'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
            'dsg_service': 60000,
          }
        },
        'A4': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.8T', '2.0T', '2.0TDI', '3.0TDI'],
          'common_faults': ['P0016', 'P0300', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        },
        'Q5': {
          'years': [2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['2.0T', '3.0T', '2.0TDI', '3.0TDI'],
          'common_faults': ['P0016', 'P0300', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        }
      }
    },

    'volkswagen': {
      'models': {
        'Golf': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.2T', '1.4T', '1.6T', '2.0T', '1.6TDI', '2.0TDI'],
          'common_faults': ['P0016', 'P0300', 'P0420', 'P2015'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
            'dsg_service': 60000,
          }
        },
        'Passat': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.4T', '1.8T', '2.0T', '2.0TDI'],
          'common_faults': ['P0016', 'P0300', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        },
        'Tiguan': {
          'years': [2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.4T', '2.0T', '2.0TDI'],
          'common_faults': ['P0016', 'P0300', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        }
      }
    },

    // FRANSIZ MARKALARI
    'renault': {
      'models': {
        'Clio': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.2', '1.2T', '1.5dCi', '0.9T'],
          'common_faults': ['P0300', 'P0171', 'P0420', 'P0128'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
            'brake_pads': 30000,
            'timing_belt': 90000,
          }
        },
        'Megane': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.2T', '1.3T', '1.5dCi', '1.6T'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
          }
        },
        'Captur': {
          'years': [2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['0.9T', '1.2T', '1.5dCi'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
          }
        }
      }
    },

    'peugeot': {
      'models': {
        '208': {
          'years': [2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.0', '1.2T', '1.4HDi', '1.6HDi'],
          'common_faults': ['P0300', 'P0171', 'P0420', 'P0234'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
            'brake_pads': 40000,
          }
        },
        '308': {
          'years': [2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.2T', '1.6T', '1.6HDi', '2.0HDi'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        },
        '3008': {
          'years': [2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.2T', '1.6T', '1.5HDi', '2.0HDi'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        }
      }
    },

    'citroen': {
      'models': {
        'C3': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.0', '1.2T', '1.4HDi', '1.6HDi'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        },
        'C4': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.2T', '1.6T', '1.6HDi', '2.0HDi'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        }
      }
    },

    // JAPON MARKALARI
    'toyota': {
      'models': {
        'Corolla': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.3', '1.4D', '1.6', '1.8', '2.0 Hybrid'],
          'common_faults': ['P0300', 'P0171', 'P0420', 'P0A80'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
            'brake_pads': 40000,
            'hybrid_battery': 160000,
          }
        },
        'Camry': {
          'years': [2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['2.0', '2.5', '3.5', '2.5 Hybrid'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
          }
        },
        'RAV4': {
          'years': [2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['2.0', '2.5', '2.5 Hybrid'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
          }
        }
      }
    },

    'honda': {
      'models': {
        'Civic': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.4', '1.6', '1.8', '2.0T', '1.6 i-DTEC'],
          'common_faults': ['P0300', 'P0171', 'P0420', 'P0562'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
            'brake_pads': 40000,
          }
        },
        'Accord': {
          'years': [2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['2.0', '2.4', '3.5', '2.0 Hybrid'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
          }
        },
        'CR-V': {
          'years': [2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.5T', '2.0', '2.4', '1.6 i-DTEC'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
          }
        }
      }
    },

    'nissan': {
      'models': {
        'Qashqai': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.2T', '1.6', '2.0', '1.5dCi', '1.6dCi'],
          'common_faults': ['P0300', 'P0171', 'P0420', 'P0101'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
            'cvt_fluid': 60000,
          }
        },
        'X-Trail': {
          'years': [2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.6T', '2.0', '2.5', '1.6dCi'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        }
      }
    },

    // KORE MARKALARI
    'hyundai': {
      'models': {
        'i20': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.0T', '1.2', '1.4', '1.6', '1.1CRDi', '1.4CRDi'],
          'common_faults': ['P0300', 'P0171', 'P0420', 'P0016'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
            'brake_pads': 30000,
          }
        },
        'Tucson': {
          'years': [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.6T', '2.0', '2.4', '1.7CRDi', '2.0CRDi'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
          }
        },
        'Elantra': {
          'years': [2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.4T', '1.6', '2.0', '1.6CRDi'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
          }
        }
      }
    },

    'kia': {
      'models': {
        'Rio': {
          'years': [2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.0T', '1.2', '1.4', '1.6', '1.1CRDi', '1.4CRDi'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
          }
        },
        'Sportage': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.6T', '2.0', '2.4', '1.7CRDi', '2.0CRDi'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
          }
        },
        'Ceed': {
          'years': [2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.0T', '1.4T', '1.6', '1.6CRDi'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
          }
        }
      }
    },

    // AMERİKAN MARKALARI
    'ford': {
      'models': {
        'Focus': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.0T', '1.5T', '1.6', '2.0', '1.5TDCi', '2.0TDCi'],
          'common_faults': ['P0300', 'P0171', 'P0420', 'P0016'],
          'maintenance_intervals': {
            'oil_change': 12500,
            'air_filter': 25000,
            'brake_pads': 35000,
          }
        },
        'Kuga': {
          'years': [2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.5T', '2.0T', '1.5TDCi', '2.0TDCi'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 12500,
            'air_filter': 25000,
          }
        },
        'Fiesta': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.0T', '1.25', '1.6', '1.4TDCi', '1.5TDCi'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 12500,
            'air_filter': 25000,
          }
        }
      }
    },

    // İTALYAN MARKALARI
    'fiat': {
      'models': {
        '500': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['0.9T', '1.2', '1.4', '1.3MultiJet'],
          'common_faults': ['P0300', 'P0171', 'P0420', 'P0234'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
            'brake_pads': 40000,
          }
        },
        'Egea': {
          'years': [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.3MultiJet', '1.4T', '1.6MultiJet'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        }
      }
    },

    // İNGİLİZ MARKALARI
    'mini': {
      'models': {
        'Cooper': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.2T', '1.5T', '2.0T', '1.5d', '2.0d'],
          'common_faults': ['P0016', 'P0300', 'P0420', 'P11A0'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
            'brake_pads': 40000,
          }
        }
      }
    },

    // ÇEŞITLI MARKALAR
    'dacia': {
      'models': {
        'Duster': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.2T', '1.3T', '1.5dCi', '1.6'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
          }
        },
        'Logan': {
          'years': [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['0.9T', '1.0T', '1.2', '1.5dCi'],
          'common_faults': ['P0300', 'P0171', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 10000,
            'air_filter': 20000,
          }
        }
      }
    },

    'skoda': {
      'models': {
        'Octavia': {
          'years': [2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.0T', '1.4T', '1.8T', '2.0T', '1.6TDI', '2.0TDI'],
          'common_faults': ['P0016', 'P0300', 'P0420', 'P2015'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
            'dsg_service': 60000,
          }
        },
        'Superb': {
          'years': [2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.4T', '1.8T', '2.0T', '2.0TDI'],
          'common_faults': ['P0016', 'P0300', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        }
      }
    },

    'seat': {
      'models': {
        'Leon': {
          'years': [2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.0T', '1.4T', '1.8T', '2.0T', '1.6TDI', '2.0TDI'],
          'common_faults': ['P0016', 'P0300', 'P0420', 'P2015'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        },
        'Ateca': {
          'years': [2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024],
          'engine_types': ['1.0T', '1.4T', '2.0T', '1.6TDI', '2.0TDI'],
          'common_faults': ['P0016', 'P0300', 'P0420'],
          'maintenance_intervals': {
            'oil_change': 15000,
            'air_filter': 30000,
          }
        }
      }
    }
  };

  // Araç bilgilerini getir
  Map<String, dynamic> getVehicleInfo(String brand, String model, int year) {
    final brandData = _vehicleData[brand.toLowerCase()];
    if (brandData == null) return {'brand': brand, 'model': model, 'year': year};

    final modelData = brandData['models']?[model];
    if (modelData == null) return {'brand': brand, 'model': model, 'year': year};

    return {
      'brand': brand,
      'model': model,
      'year': year,
      'engine_types': modelData['engine_types'] ?? [],
      'common_faults': modelData['common_faults'] ?? [],
      'maintenance_intervals': modelData['maintenance_intervals'] ?? {},
    };
  }

  // Marka listesi
  List<String> getAllBrands() {
    return _vehicleData.keys.toList()..sort();
  }

  // Model listesi
  List<String> getModelsForBrand(String brand) {
    final brandData = _vehicleData[brand.toLowerCase()];
    if (brandData == null) return [];
    
    final models = brandData['models'] as Map<String, dynamic>?;
    return models?.keys.toList() ?? [];
  }

  // Yıl listesi
  List<int> getYearsForModel(String brand, String model) {
    final brandData = _vehicleData[brand.toLowerCase()];
    if (brandData == null) return [];

    final modelData = brandData['models']?[model];
    if (modelData == null) return [];

    return List<int>.from(modelData['years'] ?? []);
  }

  // Motor türleri
  List<String> getEngineTypes(String brand, String model) {
    final brandData = _vehicleData[brand.toLowerCase()];
    if (brandData == null) return [];

    final modelData = brandData['models']?[model];
    if (modelData == null) return [];

    return List<String>.from(modelData['engine_types'] ?? []);
  }

  // Yaygın arızalar
  List<String> getCommonFaults(String brand, String model) {
    final brandData = _vehicleData[brand.toLowerCase()];
    if (brandData == null) return [];

    final modelData = brandData['models']?[model];
    if (modelData == null) return [];

    return List<String>.from(modelData['common_faults'] ?? []);
  }

  // Bakım aralıkları
  Map<String, int> getMaintenanceIntervals(String brand, String model) {
    final brandData = _vehicleData[brand.toLowerCase()];
    if (brandData == null) return {};

    final modelData = brandData['models']?[model];
    if (modelData == null) return {};

    return Map<String, int>.from(modelData['maintenance_intervals'] ?? {});
  }

  // Araç sayısı istatistikleri
  Map<String, int> getStatistics() {
    int totalBrands = _vehicleData.length;
    int totalModels = 0;
    int totalYears = 0;

    for (final brandData in _vehicleData.values) {
      final models = brandData['models'] as Map<String, dynamic>?;
      if (models != null) {
        totalModels += models.length;
        for (final modelData in models.values) {
          final years = modelData['years'] as List?;
          if (years != null) {
            totalYears += years.length;
          }
        }
      }
    }

    return {
      'total_brands': totalBrands,
      'total_models': totalModels,
      'total_year_combinations': totalYears,
    };
  }
}