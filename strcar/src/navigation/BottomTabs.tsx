import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons, MaterialCommunityIcons } from '@expo/vector-icons';
import HomeScreen from '../screens/HomeScreen';
import PerformanceScreen from '../screens/PerformanceScreen';
import ReportsScreen from '../screens/ReportsScreen';
import SettingsScreen from '../screens/SettingsScreen';
import { colors } from '../theme';

const Tab = createBottomTabNavigator();

export default function BottomTabs(): React.ReactElement {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarStyle: { backgroundColor: colors.tabBar, borderTopColor: colors.border },
        tabBarActiveTintColor: colors.text,
        tabBarInactiveTintColor: '#9aa0a6',
        tabBarIcon: ({ color, size }) => {
          if (route.name === 'Ana Menü') {
            return <Ionicons name="home" size={size} color={color} />;
          }
          if (route.name === 'Performans') {
            return <MaterialCommunityIcons name="chart-line" size={size} color={color} />;
          }
          if (route.name === 'Raporlar') {
            return <Ionicons name="document-text-outline" size={size} color={color} />;
          }
          return <Ionicons name="settings-outline" size={size} color={color} />;
        },
      })}
    >
      <Tab.Screen name="Ana Menü" component={HomeScreen} />
      <Tab.Screen name="Performans" component={PerformanceScreen} />
      <Tab.Screen name="Raporlar" component={ReportsScreen} />
      <Tab.Screen name="Ayarlar" component={SettingsScreen} />
    </Tab.Navigator>
  );
}

