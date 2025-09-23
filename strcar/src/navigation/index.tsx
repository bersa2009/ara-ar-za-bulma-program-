import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import BottomTabs from './BottomTabs';
import PlaceholderScreen from '../screens/placeholder';
import { AppTheme } from '../theme';

export type RootStackParamList = {
  Tabs: undefined;
  Faults: undefined;
  LiveData: undefined;
  SensorInfo: undefined;
  AI: undefined;
  BatteryTest: undefined;
  ServiceKm: undefined;
  VIN: undefined;
  SaveErrors: undefined;
  Update: undefined;
};

const Stack = createStackNavigator<RootStackParamList>();

export default function RootNavigation(): React.ReactElement {
  return (
    <NavigationContainer theme={AppTheme}>
      <Stack.Navigator>
        <Stack.Screen name="Tabs" component={BottomTabs} options={{ headerShown: false }} />
        <Stack.Screen name="Faults" children={() => <PlaceholderScreen title="Arıza Tespiti" />} />
        <Stack.Screen name="LiveData" children={() => <PlaceholderScreen title="Canlı Veri" />} />
        <Stack.Screen name="SensorInfo" children={() => <PlaceholderScreen title="Sensör Bilgisi" />} />
        <Stack.Screen name="AI" children={() => <PlaceholderScreen title="Yapay Zeka" />} />
        <Stack.Screen name="BatteryTest" children={() => <PlaceholderScreen title="Batarya Testi" />} />
        <Stack.Screen name="ServiceKm" children={() => <PlaceholderScreen title="Km Bakım" />} />
        <Stack.Screen name="VIN" children={() => <PlaceholderScreen title="Araç Kimlik No (VIN)" />} />
        <Stack.Screen name="SaveErrors" children={() => <PlaceholderScreen title="Hataları Kaydet" />} />
        <Stack.Screen name="Update" children={() => <PlaceholderScreen title="Güncelleme" />} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

