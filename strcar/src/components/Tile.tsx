import React from 'react';
import { Pressable, StyleSheet, Text, View, ViewStyle } from 'react-native';
import { colors } from '../theme';

type Props = {
  title: string;
  icon: React.ReactElement;
  onPress: () => void;
  style?: ViewStyle;
};

export default function Tile({ title, icon, onPress, style }: Props): React.ReactElement {
  return (
    <Pressable style={[styles.tile, style]} onPress={onPress} android_ripple={{ color: '#ffffff22' }}>
      <View style={styles.iconWrap}>{icon}</View>
      <Text style={styles.text}>{title}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  tile: {
    backgroundColor: colors.card,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 8,
  },
  iconWrap: { marginBottom: 8 },
  text: {
    color: colors.text,
    textAlign: 'center',
    fontWeight: '700',
    fontSize: 16,
    lineHeight: 20,
  },
});

