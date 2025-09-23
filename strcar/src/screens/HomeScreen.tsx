import React from 'react';
import { View, Text, StyleSheet, Pressable, FlatList } from 'react-native';
import { Ionicons, MaterialCommunityIcons } from '@expo/vector-icons';
import { colors } from '../theme';
import { useNavigation } from '@react-navigation/native';
import type { StackNavigationProp } from '@react-navigation/stack';
import type { RootStackParamList } from '../navigation';

type Tile = {
  key: string;
  title: string;
  subtitle?: string;
  icon: React.ReactElement;
};

const TILES: Tile[] = [
  { key: 'faults', title: 'Arıza\nTespiti', icon: <Ionicons name="search" size={42} color={colors.text} /> },
  { key: 'live', title: 'Canlı\nVeri', icon: <Ionicons name="wifi" size={42} color={colors.text} /> },
  { key: 'sensors', title: 'Sensör\nBilgisi', icon: <Ionicons name="stats-chart" size={42} color={colors.text} /> },
  { key: 'ai', title: 'Yapay\nZeka', icon: <MaterialCommunityIcons name="head-cog-outline" size={42} color={colors.text} /> },
  { key: 'battery', title: 'Batarva\nTesti', icon: <Ionicons name="medkit-outline" size={42} color={colors.text} /> },
  { key: 'service', title: 'Km\nBakım', icon: <MaterialCommunityIcons name="format-underline" size={42} color={colors.text} /> },
  { key: 'vin', title: 'Araç\nKimlik No', icon: <MaterialCommunityIcons name="identifier" size={42} color={colors.text} /> },
  { key: 'save', title: 'Hataları\nKaydet', icon: <Ionicons name="download-outline" size={42} color={colors.text} /> },
  { key: 'update', title: 'Güncelleme', icon: <MaterialCommunityIcons name="update" size={42} color={colors.text} /> },
];

export default function HomeScreen(): React.ReactElement {
  const navigation = useNavigation<StackNavigationProp<RootStackParamList>>();

  const onPress = (key: string) => {
    const map: Record<string, keyof RootStackParamList> = {
      faults: 'Faults',
      live: 'LiveData',
      sensors: 'SensorInfo',
      ai: 'AI',
      battery: 'BatteryTest',
      service: 'ServiceKm',
      vin: 'VIN',
      save: 'SaveErrors',
      update: 'Update',
    };
    const routeName = map[key];
    if (routeName) navigation.navigate(routeName);
  };

  const renderTile = ({ item }: { item: Tile }) => (
    <Pressable style={styles.tile} onPress={() => onPress(item.key)}>
      <View style={styles.iconWrap}>{item.icon}</View>
      <Text style={styles.tileText}>{item.title}</Text>
    </Pressable>
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Ionicons name="car" size={22} color={colors.text} />
        <Text style={styles.headerText}>Renault Clio 2018 — Bağlı</Text>
      </View>
      <FlatList
        data={TILES}
        keyExtractor={(t) => t.key}
        renderItem={renderTile}
        numColumns={3}
        columnWrapperStyle={styles.row}
        contentContainerStyle={styles.grid}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    gap: 8,
  },
  headerText: {
    color: colors.text,
    fontSize: 18,
    fontWeight: '600',
  },
  grid: {
    padding: 16,
    gap: 16,
  },
  row: {
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  tile: {
    backgroundColor: colors.card,
    borderRadius: 14,
    width: '31%',
    aspectRatio: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 8,
  },
  iconWrap: {
    marginBottom: 8,
  },
  tileText: {
    color: colors.text,
    textAlign: 'center',
    fontWeight: '700',
    fontSize: 16,
    lineHeight: 20,
  },
});

