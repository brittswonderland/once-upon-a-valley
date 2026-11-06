import React,{useEffect,useState} from 'react';
import {SafeAreaView,ScrollView,Text,TextInput,TouchableOpacity,View,StyleSheet,Alert} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {StatusBar} from 'expo-status-bar';
import {supabase} from './src/client';
type Entry={id:string;name:string;kind:'Furniture'|'Clothing';owned:boolean};
const KEY='valley-dev-local-items';
export default function App(){
 const [items,setItems]=useState<Entry[]>([]),[name,setName]=useState(''),[kind,setKind]=useState<'Furniture'|'Clothing'>('Furniture'),[tab,setTab]=useState('Home');
 useEffect(()=>{AsyncStorage.getItem(KEY).then(v=>{if(v)setItems(JSON.parse(v))}).catch(()=>{})},[]);
 async function persist(next:Entry[]){setItems(next);await AsyncStorage.setItem(KEY,JSON.stringify(next))}
 function add(){if(!name.trim())return;persist([{id:Date.now().toString(),name:name.trim(),kind,owned:true},...items]);setName('')}
 return <SafeAreaView style={s.root}><StatusBar style="dark"/><ScrollView contentContainerStyle={s.body}>
 <Text style={s.brand}>✦ Once Upon a Valley</Text><Text style={s.tag}>A little magic for every valley.</Text>
 <Text style={s.note}>PRIVATE DEVELOPMENT • Local starter data only</Text>
 <View style={s.nav}>{['Home','Collection','Cozy','Settings'].map(x=><TouchableOpacity key={x} style={[s.chip,tab===x&&s.active]} onPress={()=>setTab(x)}><Text style={s.chipText}>{x}</Text></TouchableOpacity>)}</View>
 {tab==='Home'&&<View style={s.card}><Text style={s.title}>Welcome to your valley 💜</Text><Text>Track what you own, save favorites, and plan your next cozy session.</Text><Text style={s.muted}>Your tracked items: {items.length} · Owned: {items.filter(x=>x.owned).length}</Text></View>}
 {tab==='Collection'&&<View style={s.card}><Text style={s.title}>My Furniture & Clothing</Text><Text style={s.muted}>Personal manual entries until the verified catalog is connected.</Text><TextInput value={name} onChangeText={setName} placeholder="Item name" style={s.input}/><View style={s.nav}>{(['Furniture','Clothing'] as const).map(k=><TouchableOpacity key={k} style={[s.chip,kind===k&&s.active]} onPress={()=>setKind(k)}><Text>{k}</Text></TouchableOpacity>)}</View><TouchableOpacity style={s.button} onPress={add}><Text style={s.buttonText}>Add owned item</Text></TouchableOpacity>{items.map(item=><View style={s.item} key={item.id}><View style={{flex:1}}><Text style={s.itemName}>{item.name}</Text><Text style={s.muted}>{item.kind} · {item.owned?'Owned':'Wishlist'}</Text></View><TouchableOpacity onPress={()=>persist(items.map(x=>x.id===item.id?{...x,owned:!x.owned}:x))}><Text style={s.link}>Toggle</Text></TouchableOpacity><TouchableOpacity onPress={()=>Alert.alert('Remove item?','This cannot be undone',[{text:'Cancel'},{text:'Remove',style:'destructive',onPress:()=>persist(items.filter(x=>x.id!==item.id))}])}><Text style={s.link}>Remove</Text></TouchableOpacity></View>)}</View>}
 {tab==='Cozy'&&<View style={s.card}><Text style={s.title}>Cozy Mode 🌷</Text><Text>Enjoy your valley at your own pace. No streaks, no pressure.</Text><Text style={s.muted}>Personalized recommendations are planned, not yet connected.</Text></View>}
 {tab==='Settings'&&<View style={s.card}><Text style={s.title}>Settings</Text><Text>Content: Base game only</Text><Text>Playstyle: No preference</Text><Text>Frequency: Casual</Text><Text style={s.muted}>Local-only starter. Cloud accounts and editable onboarding are upcoming work.</Text><Text style={s.muted}>Cloud configured: {supabase?'Yes (not yet syncing)':'No'}</Text></View>}
 </ScrollView></SafeAreaView>
}
const s=StyleSheet.create({root:{flex:1,backgroundColor:'#F8F4FC'},body:{padding:20,gap:16},brand:{fontSize:26,fontWeight:'700',color:'#6B4A91'},tag:{color:'#846E99'},note:{color:'#9B6E49',fontSize:11,letterSpacing:1},nav:{flexDirection:'row',flexWrap:'wrap',gap:8},chip:{padding:10,borderRadius:12,backgroundColor:'#EDE4F7'},active:{backgroundColor:'#D7C0EE'},chipText:{fontSize:13,color:'#4C3268'},card:{backgroundColor:'white',padding:18,borderRadius:18,gap:12},title:{fontSize:21,fontWeight:'700',color:'#5A3A7A'},muted:{color:'#756984',fontSize:13},input:{borderWidth:1,borderColor:'#DCCBEF',padding:12,borderRadius:10},button:{backgroundColor:'#8862B3',padding:14,borderRadius:12,alignItems:'center'},buttonText:{color:'white',fontWeight:'700'},item:{flexDirection:'row',alignItems:'center',gap:12,borderTopWidth:1,borderColor:'#EEE7F4',paddingTop:12},itemName:{fontWeight:'600'},link:{color:'#74509C'}});
