import { useEffect, useState } from 'react'
import { useLiveQuery } from 'dexie-react-hooks'
import { db, todayStr, getStreak } from '../db/db'
import PapaAvatar from '../components/PapaAvatar'
function last7(){return Array.from({length:7},(_,i)=>{const d=new Date();d.setDate(d.getDate()-6+i);d.setHours(0,0,0,0);return d.toISOString().split('T')[0]})}
const DAYS=['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
export default function Progress(){
  const [streak,setStreak]=useState(0)
  const tasks=useLiveQuery(()=>db.tasks.toArray(),[])??[]
  const progress=useLiveQuery(()=>db.progress.toArray(),[])??[]
  useEffect(()=>{getStreak().then(setStreak)},[progress])
  const totalDone=tasks.filter(t=>t.isCompleted).length
  const totalTasks=tasks.length
  const days=last7()
  const BADGES=[{icon:'⭐',label:'First Task',earned:totalDone>=1},{icon:'🏆',label:'10 Tasks',earned:totalDone>=10},{icon:'🔥',label:'3-Day Streak',earned:streak>=3},{icon:'💎',label:'30 Tasks',earned:totalDone>=30},{icon:'🌟',label:'7-Day Streak',earned:streak>=7},{icon:'👑',label:'50 Tasks',earned:totalDone>=50}]
  return(
    <div className="page-in" style={{display:'flex',flexDirection:'column',height:'100%',overflow:'hidden'}}>
      <div style={{padding:'env(safe-area-inset-top,44px) 18px 0',paddingTop:'calc(env(safe-area-inset-top,44px) + 8px)',flexShrink:0}}>
        <div style={{fontSize:22,fontWeight:700,color:'#F0C866',fontFamily:'Georgia,serif',marginBottom:14}}>Progress</div>
      </div>
      <div className="scroll-y" style={{flex:1,padding:'0 18px 24px'}}>
        <div style={{background:'linear-gradient(135deg,rgba(200,150,42,0.16),rgba(232,184,75,0.06))',border:'1px solid rgba(200,150,42,0.38)',borderRadius:18,padding:16,marginBottom:14,display:'flex',alignItems:'center',gap:14}}>
          <PapaAvatar state={totalDone>0?'happy':'calm'} size={72} showRings={false}/>
          <div style={{flex:1}}>
            <div style={{fontSize:28,fontWeight:700,color:'#F0C866',lineHeight:1,fontFamily:'Georgia,serif'}}>{streak} Day{streak!==1?'s':''} 🔥</div>
            <div style={{fontSize:11,color:'rgba(200,150,42,0.65)',marginTop:3}}>{streak>0?'"Keep going! You are on fire!"':'"Start today to begin your streak!"'}</div>
          </div>
          <div style={{textAlign:'center'}}>
            <div style={{fontSize:22,fontWeight:700,color:'#EEE8D5'}}>{totalDone}</div>
            <div style={{fontSize:9,color:'rgba(200,184,160,0.5)'}}>Tasks done</div>
          </div>
        </div>
        <div style={{background:'rgba(255,255,255,0.04)',border:'1px solid rgba(255,255,255,0.07)',borderRadius:16,padding:14,marginBottom:14}}>
          <div style={{fontSize:10,fontWeight:600,letterSpacing:'.09em',textTransform:'uppercase',color:'rgba(200,150,42,0.55)',marginBottom:12}}>This Week</div>
          <div style={{display:'flex',alignItems:'flex-end',gap:5,height:60}}>
            {days.map(day=>{
              const rec=progress.find(p=>p.date===day)
              const done=rec?.tasksCompleted??0
              const total=rec?.tasksTotal??0
              const pct=total>0?done/total:0
              const isToday=day===todayStr()
              return(
                <div key={day} style={{flex:1,display:'flex',flexDirection:'column',alignItems:'center',gap:4}}>
                  <div style={{width:'100%',borderRadius:4,background:isToday?(done>0?'#C8962A':'rgba(200,150,42,0.35)'):done>0?'#4CAF82':'rgba(255,255,255,0.08)',height:Math.max(pct*54,6),border:isToday&&done===0?'1.5px dashed rgba(200,150,42,0.5)':'none'}}/>
                  <div style={{fontSize:8,color:isToday?'#C8962A':'rgba(200,184,160,0.38)',fontWeight:isToday?700:400}}>{DAYS[new Date(day+'T12:00:00').getDay()]}</div>
                </div>
              )
            })}
          </div>
        </div>
        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:10,marginBottom:14}}>
          <div style={{background:'rgba(255,255,255,0.04)',border:'1px solid rgba(255,255,255,0.07)',borderRadius:14,padding:14,textAlign:'center'}}>
            <div style={{fontSize:28,fontWeight:700,color:'#F0C866'}}>{totalDone}</div>
            <div style={{fontSize:11,color:'rgba(200,184,160,0.5)',marginTop:2}}>Tasks completed</div>
          </div>
          <div style={{background:'rgba(255,255,255,0.04)',border:'1px solid rgba(255,255,255,0.07)',borderRadius:14,padding:14,textAlign:'center'}}>
            <div style={{fontSize:28,fontWeight:700,color:'#4CAF82'}}>{totalTasks>0?Math.round(totalDone/totalTasks*100):0}%</div>
            <div style={{fontSize:11,color:'rgba(200,184,160,0.5)',marginTop:2}}>Completion rate</div>
          </div>
        </div>
        <div style={{fontSize:10,fontWeight:600,letterSpacing:'.09em',textTransform:'uppercase',color:'rgba(200,150,42,0.55)',marginBottom:10}}>Achievements</div>
        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:8}}>
          {BADGES.map(b=>(
            <div key={b.label} style={{background:b.earned?'rgba(200,150,42,0.1)':'rgba(255,255,255,0.03)',border:`1px solid ${b.earned?'rgba(200,150,42,0.3)':'rgba(255,255,255,0.06)'}`,borderRadius:14,padding:12,textAlign:'center',opacity:b.earned?1:0.45}}>
              <div style={{fontSize:24,marginBottom:4}}>{b.icon}</div>
              <div style={{fontSize:11,fontWeight:600,color:b.earned?'#F0C866':'rgba(200,184,160,0.45)'}}>{b.label}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
