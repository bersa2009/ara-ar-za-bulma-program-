import React, { useEffect, useMemo, useRef, useState } from 'react';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { LinearGradient } from 'expo-linear-gradient';
import { StyleSheet, Text, View, Pressable, Modal, Platform, FlatList } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { RootStackParamList } from '../../App';
import { MaterialIcons } from '@expo/vector-icons';

type Navigation = NativeStackNavigationProp<RootStackParamList, 'Welcome'>;

type ObdDevice = {
  id: string;
  name: string;
};

const BRAND_OPTIONS = ['Renault'];
const MODEL_OPTIONS: Record<string, string[]> = {
  Renault: ['Clio', 'Megane', 'Symbol'],
};
const YEAR_OPTIONS = Array.from({ length: 15 }, (_, i) => `${2010 + i}`);

export default function WelcomeScreen() {
  const navigation = useNavigation<Navigation>();

  const [isPromptVisible, setPromptVisible] = useState(true);
  const [selectedBrand, setSelectedBrand] = useState<string>('Renault');
  const [selectedModel, setSelectedModel] = useState<string>('Clio');
  const [selectedYear, setSelectedYear] = useState<string>('2018');

  const [scanProgress, setScanProgress] = useState<number>(0);
  const [devices, setDevices] = useState<ObdDevice[]>([]);
  const [connectedDevice, setConnectedDevice] = useState<ObdDevice | null>(null);

  const progressRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const saved = await AsyncStorage.getItem('vehicleSelection');
        if (saved) {
          const { brand, model, year } = JSON.parse(saved);
          if (brand) setSelectedBrand(brand);
          if (model) setSelectedModel(model);
          if (year) setSelectedYear(year);
        }
      } catch {}
    })();
  }, []);

  useEffect(() => {
    const models = MODEL_OPTIONS[selectedBrand] ?? [];
    if (!models.includes(selectedModel)) {
      setSelectedModel(models[0] ?? '');
    }
  }, [selectedBrand]);

  const visibleModels = useMemo(() => MODEL_OPTIONS[selectedBrand] ?? [], [selectedBrand]);

  const handleRequestBluetooth = () => {
    setPromptVisible(false);
    startMockScan();
  };

  const handleRequestWifi = () => {
    setPromptVisible(false);
    startMockScan();
  };

  const saveSelection = async (brand: string, model: string, year: string) => {
    try {
      await AsyncStorage.setItem('vehicleSelection', JSON.stringify({ brand, model, year }));
    } catch {}
  };

  const startMockScan = () => {
    if (progressRef.current) {
      clearInterval(progressRef.current);
    }
    setConnectedDevice(null);
    setDevices([]);
    setScanProgress(0);

    // Mock devices appear during scan
    const found: ObdDevice[] = [
      { id: 'vgate', name: 'Vgate iCar' },
      { id: 'elm327', name: 'ELM327_BT123' },
    ];

    let tick = 0;
    progressRef.current = setInterval(() => {
      tick += 1;
      setScanProgress(Math.min(100, tick * 8));
      if (tick === 4) {
        setDevices(found.slice(0, 1));
      }
      if (tick === 6) {
        setDevices(found);
      }
      if (tick >= 12) {
        clearInterval(progressRef.current as NodeJS.Timeout);
        // Choose most compatible device (mock: prefer Vgate)
        const chosen = found[0];
        setConnectedDevice(chosen);
        setScanProgress(100);
      }
    }, 500);
  };

  const handleContinue = async () => {
    await saveSelection(selectedBrand, selectedModel, selectedYear);
    navigation.navigate('Home');
  };

  return (
    <LinearGradient colors={["#0D47A1", "#1976D2"]} style={styles.gradient}>
      <View style={styles.header}>
        <View style={styles.headerRow}>
          <MaterialIcons name="directions-car" color="#FFFFFF" size={28} />
          <Text style={styles.welcome}> Hoş Geldiniz </Text>
          <MaterialIcons name="directions-car" color="#FFFFFF" size={28} />
        </View>
        <Text style={styles.brand}>Strcar</Text>
      </View>

      {/* Connection Prompt */}
      <View style={styles.card}>
        <View style={styles.cardRow}>
          <MaterialIcons name="wifi" size={22} color="#0D47A1" />
          <Text style={styles.cardText}>Bluetooth ve Wi‑Fi bağlantısı gerekli. Açmak ister misiniz?</Text>
        </View>
        <View style={styles.row}>
          <Pressable style={[styles.button, styles.primary]} onPress={handleRequestBluetooth}>
            <Text style={[styles.buttonText, styles.primaryText]}>Bluetooth’u Aç</Text>
          </Pressable>
          <Pressable style={[styles.button, styles.outlined]} onPress={handleRequestWifi}>
            <Text style={[styles.buttonText, styles.outlinedText]}>Wi‑Fi’yi Aç</Text>
          </Pressable>
        </View>
      </View>

      {/* Vehicle Selection */}
      <View style={styles.form}>
        <View style={styles.inputGroup}>
          <Text style={styles.label}>Marka</Text>
          <View style={styles.pickerWrapper}>
            <Picker
              selectedValue={selectedBrand}
              onValueChange={(v) => setSelectedBrand(v)}
              dropdownIconColor="#0D47A1"
            >
              {BRAND_OPTIONS.map((b) => (
                <Picker.Item label={b} value={b} key={b} />
              ))}
            </Picker>
          </View>
        </View>
        <View style={styles.inputGroup}>
          <Text style={styles.label}>Model</Text>
          <View style={styles.pickerWrapper}>
            <Picker
              selectedValue={selectedModel}
              onValueChange={(v) => setSelectedModel(v)}
              dropdownIconColor="#0D47A1"
            >
              {visibleModels.map((m) => (
                <Picker.Item label={m} value={m} key={m} />
              ))}
            </Picker>
          </View>
        </View>
        <View style={styles.inputGroup}>
          <Text style={styles.label}>Yıl</Text>
          <View style={styles.pickerWrapper}>
            <Picker
              selectedValue={selectedYear}
              onValueChange={(v) => setSelectedYear(v)}
              dropdownIconColor="#0D47A1"
            >
              {YEAR_OPTIONS.map((y) => (
                <Picker.Item label={y} value={y} key={y} />
              ))}
            </Picker>
          </View>
        </View>
      </View>

      {/* Scan Progress */}
      <View style={styles.scanCard}>
        <View style={styles.progressTrack}>
          <View style={[styles.progressBar, { width: `${scanProgress}%` }]} />
        </View>
        <Text style={styles.scanText}>Tarama… {scanProgress}%</Text>
        <FlatList
          data={devices}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <Text style={styles.deviceItem}>{item.name}</Text>
          )}
          ListFooterComponent={
            connectedDevice ? (
              <View style={styles.successRow}>
                <Text style={styles.successIcon}>✓</Text>
                <Text style={styles.successText}>Bağlantı Başarılı</Text>
                <Text style={styles.successSub}>{`${selectedBrand} ${selectedModel} ${selectedYear}`}</Text>
              </View>
            ) : null
          }
        />
      </View>

      <Pressable
        accessibilityRole="button"
        style={[styles.bottomButton, !connectedDevice && styles.bottomButtonDisabled]}
        onPress={handleContinue}
        disabled={!connectedDevice}
      >
        <Text style={styles.bottomButtonText}>Devam Et</Text>
      </Pressable>

      {/* Invisible modal placeholder for future native prompts */}
      <Modal visible={false} />
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  gradient: {
    flex: 1,
    paddingTop: Platform.select({ ios: 56, android: 32, default: 32 }),
    paddingHorizontal: 16,
  },
  header: {
    alignItems: 'center',
    marginBottom: 16,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  welcome: {
    color: 'white',
    fontSize: 36,
    fontWeight: '800',
  },
  brand: {
    color: 'white',
    fontSize: 28,
    fontWeight: '600',
    marginTop: 4,
  },
  card: {
    backgroundColor: 'rgba(255,255,255,0.95)',
    borderRadius: 16,
    padding: 16,
    marginBottom: 16,
  },
  cardRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  cardText: {
    color: '#0F172A',
    fontSize: 16,
    marginBottom: 12,
  },
  row: {
    flexDirection: 'row',
    gap: 12,
  },
  button: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
  },
  buttonText: {
    fontSize: 16,
    fontWeight: '700',
  },
  primary: {
    backgroundColor: '#1976D2',
    borderColor: '#1976D2',
  },
  primaryText: {
    color: 'white',
  },
  outlined: {
    backgroundColor: 'transparent',
    borderColor: '#E2E8F0',
  },
  outlinedText: {
    color: '#0D47A1',
  },
  form: {
    marginBottom: 16,
    gap: 12,
  },
  inputGroup: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 12,
  },
  label: {
    color: '#334155',
    fontSize: 12,
    marginBottom: 4,
  },
  pickerWrapper: {
    borderWidth: 1,
    borderColor: '#E2E8F0',
    borderRadius: 8,
  },
  scanCard: {
    backgroundColor: 'white',
    borderRadius: 16,
    padding: 12,
    flex: 1,
  },
  progressTrack: {
    height: 6,
    backgroundColor: '#E2E8F0',
    borderRadius: 999,
    overflow: 'hidden',
  },
  progressBar: {
    height: 6,
    backgroundColor: '#1976D2',
  },
  scanText: {
    marginTop: 8,
    marginBottom: 8,
    color: '#334155',
  },
  deviceItem: {
    paddingVertical: 6,
    color: '#0F172A',
  },
  successRow: {
    marginTop: 8,
    paddingTop: 4,
    borderTopWidth: 1,
    borderTopColor: '#E2E8F0',
  },
  successIcon: {
    color: '#16A34A',
    fontSize: 24,
    marginBottom: 4,
  },
  successText: {
    fontWeight: '700',
    color: '#16A34A',
  },
  successSub: {
    color: '#334155',
    marginTop: 2,
  },
  bottomButton: {
    marginTop: 12,
    backgroundColor: '#1E88E5',
    borderRadius: 16,
    paddingVertical: 16,
    alignItems: 'center',
  },
  bottomButtonDisabled: {
    opacity: 0.5,
  },
  bottomButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: '800',
  },
});
