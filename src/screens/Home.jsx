import { useEffect, useState } from 'react'
import PapaAvatar from '../components/PapaAvatar'
import { db, todayStr, getStreak } from '../db/db'
import { useLiveQuery } from 'dexie-react-hooks'
function timeGreeting(){const h=new Date().getHours();if(h<12)return'Good Morning';if(h<17)return'Good Afternoon';if(h<21)return'Good Evening';return'Good Night'}
const pColor={high:'#E8855A',medium:'#C8962A',low:'#4CAF82'}
export default function Home({onNav}){
  const [streak,setStreak]=useState(0)
  const today=todayStr()
  const todayTasks=useLiveQuery(()=>db.tasks.where('dueDate').equals(today).toArray(),[])??[]
  const allTasks=useLiveQuery(()=>db.tasks.toArray(),[])??[]
  useEffect(()=>{getStreak().then(setStreak)},[todayTasks])
  const done=todayTasks.filter(t=>t.isCompleted).length
  const total=todayTasks.length
  const overdue=allTasks.filter(t=>!t.isCompleted&&t.dueDate&&t.dueDate<today)
  const avState=overdue.length>0?'concern':done>0&&done===total&&total>0?'happy':'calm'
  const msgs={calm:total>0?`You have ${total} task${total>1?'s':''} today.${streak>0?' You are on a '+streak+'-day streak!':''}`:'A calm day. Want to add something?',happy:"You completed everything today! I am so proud of you!",concern:`You have ${overdue.length} task${overdue.length>1?'s':''} waiting. Whenever you are ready.`}
  async function completeTask(task){
    await db.tasks.update(task.id,{isCompleted:true,completedAt:new Date().toISOString()})
    const existing=await db.progress.where('date').equals(today).first()
    if(existing)await db.progress.update(existing.id,{tasksCompleted:(existing.tasksCompleted||0)+1})
    else await db.progress.add({date:today,tasksCompleted:1,tasksTotal:total})
    setStreak(await getStreak())
  }
  return(
    <div className="page-in" style={{display:'flex',flexDirection:'column',height:'100%',overflow:'hidden'}}>
      <div style={{paddingTop:'env(safe-area-inset-top,44px)',flexShrink:0}}>
        <div style={{display:'flex',justifyContent:'space-between',padding:'8px 18px 0',marginBottom:10}}>
          <span style={{fontSize:12,color:'rgba(200,150,42,0.5)'}}>{new Date().toLocaleDateString('en-IN',{weekday:'short',day:'numeric',month:'short'})}</span>
          <span style={{fontSize:12,color:'rgba(200,150,42,0.5)'}}>{new Date().toLocaleTimeString('en-IN',{hour:'2-digit',minute:'2-digit'})}</span>
        </div>
      </div>
      <div className="scroll-y" style={{flex:1,padding:'0 18px 24px'}}>
        <div style={{display:'flex',alignItems:'center',gap:14,marginBottom:14}}>
          <PapaAvatar state={avState} size={62} showRings={true}/>
          <div>
            <div style={{fontSize:12,color:'rgba(200,150,42,0.6)',fontWeight:500}}>{timeGreeting()},</div>
            <div style={{fontSize:22,fontWeight:700,color:'#F0C866',lineHeight:1.1,fontFamily:'Georgia,serif'}}>Papa ✦</div>
          </div>
          <button onClick={()=>onNav('tasks')} style={{marginLeft:'auto',background:'rgba(200,150,42,0.12)',border:'1px solid rgba(200,150,42,0.28)',borderRadius:'50%',width:36,height:36,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer',fontSize:18,color:'#F0C866',fontWeight:700}}>+</button>
        </div>
        <div style={{background:avState==='concern'?'rgba(232,133,90,0.1)':'rgba(200,150,42,0.1)',border:`1px solid ${avState==='concern'?'rgba(232,133,90,0.3)':'rgba(200,150,42,0.28)'}`,borderRadius:14,borderTopLeftRadius:4,padding:'10px 13px',fontSize:13,color:'#E8D8B0',lineHeight:1.55,marginBottom:14}}>{msgs[avState]}</div>
        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr 1fr',gap:8,marginBottom:16}}>
          {[{val:total,label:'Tasks',c:'#4CAF82',bg:'rgba(76,175,130,0.12)',bd:'rgba(76,175,130,0.25)'},{val:streak+'🔥',label:'Streak',c:'#F0C866',bg:'rgba(200,150,42,0.12)',bd:'rgba(200,150,42,0.28)'},{val:done+'/'+total,label:'Done',c:'#6496E8',bg:'rgba(100,150,230,0.12)',bd:'rgba(100,150,230,0.25)'}].map(s=>(
            <div key={s.label} style={{background:s.bg,border:`1px solid ${s.bd}`,borderRadius:12,padding:'10px 6px',textAlign:'center'}}>
              <div style={{fontSize:20,fontWeight:700,color:s.c}}>{s.val}</div>
              <div style={{fontSize:9,color:s.c,opacity:.7,marginTop:2}}>{s.label}</div>
            </div>
          ))}
        </div>
        <div style={{fontSize:10,fontWeight:600,letterSpacing:'.09em',textTransform:'uppercase',color:'rgba(200,150,42,0.58)',marginBottom:8}}>Today s Tasks</div>
        {todayTasks.length===0&&<div style={{textAlign:'center',padding:'28px 0',color:'rgba(200,184,160,0.4)',fontSize:14}}>No tasks for today.<br/><span style={{fontSize:12}}>Tap + to add one</span></div>}
        <div style={{display:'flex',flexDirection:'column',gap:8}}>
          {todayTasks.map(task=>(
            <div key={task.id} onClick={()=>!task.isCompleted&&completeTask(task)} style={{background:task.isCompleted?'rgba(76,175,130,0.07)':'rgba(255,255,255,0.045)',border:`1.5px solid ${task.isCompleted?'rgba(76,175,130,0.22)':task.priority==='high'?'rgba(232,133,90,0.4)':'rgba(200,150,42,0.25)'}`,borderRadius:14,padding:'11px 13px',display:'flex',alignItems:'center',gap:10,opacity:task.isCompleted?0.7:1,cursor:task.isCompleted?'default':'pointer'}}>
              <div style={{width:22,height:22,borderRadius:'50%',border:`2px solid ${task.isCompleted?'#4CAF82':pColor[task.priority]||'rgba(255,255,255,0.3)'}`,background:task.isCompleted?'rgba(76,175,130,0.25)':'transparent',display:'flex',alignItems:'center',justifyContent:'center',flexShrink:0}}>
                {task.isCompleted&&<span style={{color:'#4CAF82',fontSize:11}}>✓</span>}
              </div>
              <div style={{flex:1,minWidth:0}}>
                <div style={{fontSize:13,fontWeight:600,color:task.isCompleted?'rgba(200,184,160,0.45)':'#EEE8D5',textDecoration:task.isCompleted?'line-through':'none',whiteSpace:'nowrap',overflow:'hidden',textOverflow:'ellipsis'}}>{task.title}</div>
                <div style={{fontSize:10,color:'rgba(200,150,42,0.6)',marginTop:1}}>{task.isCompleted?'Done ✓':task.category||''}</div>
              </div>
              {!task.isCompleted&&task.priority==='high'&&<div style={{background:'rgba(232,133,90,0.2)',color:'#E8855A',padding:'2px 8px',borderRadius:8,fontSize:9,fontWeight:700}}>!</div>}
            </div>
          ))}
        </div>
        {overdue.length>0&&(
          <div onClick={()=>onNav('tasks')} style={{marginTop:12,background:'rgba(232,133,90,0.08)',border:'1px solid rgba(232,133,90,0.28)',borderRadius:12,padding:'10px 13px',display:'flex',alignItems:'center',gap:10,cursor:'pointer'}}>
            <span style={{fontSize:18}}>⚠️</span>
            <div><div style={{fontSize:12,fontWeight:600,color:'#E8855A'}}>{overdue.length} overdue task{overdue.length>1?'s':''}</div><div style={{fontSize:10,color:'rgba(232,133,90,0.65)'}}>Tap to view</div></div>
          </div>
        )}
      </div>
    </div>
  )
}
