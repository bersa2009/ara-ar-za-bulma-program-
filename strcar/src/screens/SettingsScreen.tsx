import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors } from '../theme';

export default function SettingsScreen(): React.ReactElement {
  return (
    <View style={styles.container}>
      <Text style={styles.text}>Ayarlar (Dil, Hakkında, Destek)</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: colors.background },
  text: { color: colors.text },
});

