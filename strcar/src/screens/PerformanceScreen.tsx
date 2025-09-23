import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors } from '../theme';

export default function PerformanceScreen(): React.ReactElement {
  return (
    <View style={styles.container}>
      <Text style={styles.text}>Performans (Grafikler ve metrikler yakında)</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: colors.background },
  text: { color: colors.text },
});

