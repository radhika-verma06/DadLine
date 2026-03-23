import { useState } from 'react'
import { useLiveQuery } from 'dexie-react-hooks'
import { db, todayStr } from '../db/db'
const PC={high:'#E8855A',medium:'#C8962A',low:'#4CAF82'}
const PBG={high:'rgba(232,133,90,0.12)',medium:'rgba(200,150,42,0.1)',low:'rgba(76,175,130,0.1)'}
const PBD={high:'rgba(232,133,90,0.35)',medium:'rgba(200,150,42,0.32)',low:'rgba(76,175,130,0.28)'}
const CATS=['Health','Personal','Home','Work','Family','Other']
function Sheet({onClose}){
  const [title,setTitle]=useState('')
  const [pri,setPri]=useState('medium')
  const [cat,setCat]=useState('Personal')
  const [due,setDue]=useState(todayStr())
  const [notes,setNotes]=useState('')
  async function save(){if(!title.trim())return;await db.tasks.add({title:title.trim(),priority:pri,category:cat,dueDate:due,notes,isCompleted:false,createdAt:new Date().toISOString(),completedAt:null,reminder:''});onClose()}
  const I={background:'rgba(255,255,255,0.07)',border:'1px solid rgba(200,150,42,0.28)',borderRadius:12,padding:'12px 14px',fontSize:15,color:'#EEE8D5',width:'100%',fontFamily:'inherit',outline:'none'}
  return(
    <div style={{position:'fixed',inset:0,zIndex:200,display:'flex',flexDirection:'column',justifyContent:'flex-end'}}>
      <div onClick={onClose} style={{position:'absolute',inset:0,background:'rgba(0,0,0,0.55)'}}/>
      <div className="slide-up" style={{position:'relative',background:'#0D1B2A',borderRadius:'20px 20px 0 0',padding:'20px 18px',paddingBottom:'env(safe-area-inset-bottom,20px)',border:'1px solid rgba(200,150,42,0.2)',borderBottom:'none',maxHeight:'85vh',overflowY:'auto'}}>
        <div style={{width:36,height:4,background:'rgba(200,150,42,0.3)',borderRadius:2,margin:'0 auto 18px'}}/>
        <div style={{fontSize:18,fontWeight:700,color:'#F0C866',fontFamily:'Georgia,serif',marginBottom:18}}>Add Task</div>
        <div style={{marginBottom:14}}>
          <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.6)',marginBottom:6}}>Task</div>
          <input style={I} placeholder="What needs to be done?" value={title} onChange={e=>setTitle(e.target.value)} autoFocus/>
        </div>
        <div style={{marginBottom:14}}>
          <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.6)',marginBottom:6}}>Priority</div>
          <div style={{display:'flex',gap:8}}>
            {['high','medium','low'].map(p=>(
              <button key={p} onClick={()=>setPri(p)} style={{flex:1,padding:'9px 0',borderRadius:20,fontSize:12,fontWeight:600,border:`${pri===p?'2px':'1px'} solid ${pri===p?PC[p]:'rgba(255,255,255,0.12)'}`,background:pri===p?PBG[p]:'transparent',color:pri===p?PC[p]:'rgba(200,184,160,0.55)',cursor:'pointer',fontFamily:'inherit',textTransform:'capitalize'}}>{p}</button>
            ))}
          </div>
        </div>
        <div style={{marginBottom:14}}>
          <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.6)',marginBottom:6}}>Category</div>
          <div style={{display:'flex',flexWrap:'wrap',gap:7}}>
            {CATS.map(c=>(
              <button key={c} onClick={()=>setCat(c)} style={{padding:'6px 13px',borderRadius:20,fontSize:11,fontWeight:600,border:`1px solid ${cat===c?'#C8962A':'rgba(255,255,255,0.1)'}`,background:cat===c?'rgba(200,150,42,0.15)':'transparent',color:cat===c?'#F0C866':'rgba(200,184,160,0.5)',cursor:'pointer',fontFamily:'inherit'}}>{c}</button>
            ))}
          </div>
        </div>
        <div style={{marginBottom:14}}>
          <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.6)',marginBottom:6}}>Due Date</div>
          <input type="date" style={{...I,colorScheme:'dark'}} value={due} onChange={e=>setDue(e.target.value)}/>
        </div>
        <div style={{marginBottom:20}}>
          <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.6)',marginBottom:6}}>Notes</div>
          <textarea style={{...I,resize:'none',minHeight:72}} placeholder="Any details..." value={notes} onChange={e=>setNotes(e.target.value)}/>
        </div>
        <button onClick={save} style={{background:'linear-gradient(135deg,#C8962A,#E8B84B)',color:'#060E16',fontWeight:700,borderRadius:14,border:'none',cursor:'pointer',fontSize:16,width:'100%',padding:'15px',fontFamily:'inherit'}}>Save Task</button>
      </div>
    </div>
  )
}
export default function Tasks(){
  const [filter,setFilter]=useState('all')
  const [showAdd,setShowAdd]=useState(false)
  const tasks=useLiveQuery(()=>db.tasks.orderBy('createdAt').reverse().toArray(),[])??[]
  const today=todayStr()
  const filtered=tasks.filter(t=>{
    if(filter==='today')return t.dueDate===today
    if(filter==='high')return t.priority==='high'&&!t.isCompleted
    if(filter==='done')return t.isCompleted
    if(filter==='overdue')return !t.isCompleted&&t.dueDate&&t.dueDate<today
    return true
  })
  async function toggle(task){
    const done=!task.isCompleted
    await db.tasks.update(task.id,{isCompleted:done,completedAt:done?new Date().toISOString():null})
    if(done){const e=await db.progress.where('date').equals(today).first();if(e)await db.progress.update(e.id,{tasksCompleted:(e.tasksCompleted||0)+1});else await db.progress.add({date:today,tasksCompleted:1,tasksTotal:tasks.filter(t=>t.dueDate===today).length})}
  }
  const FILTERS=[{id:'all',label:'All'},{id:'today',label:'Today'},{id:'high',label:'High !'},{id:'overdue',label:'Overdue'},{id:'done',label:'Done'}]
  return(
    <div className="page-in" style={{display:'flex',flexDirection:'column',height:'100%',overflow:'hidden'}}>
      {showAdd&&<Sheet onClose={()=>setShowAdd(false)}/>}
      <div style={{padding:'env(safe-area-inset-top,44px) 18px 0',paddingTop:'calc(env(safe-area-inset-top,44px) + 8px)',flexShrink:0}}>
        <div style={{display:'flex',alignItems:'center',marginBottom:14}}>
          <div style={{fontSize:22,fontWeight:700,color:'#F0C866',fontFamily:'Georgia,serif'}}>Tasks</div>
          <button onClick={()=>setShowAdd(true)} style={{marginLeft:'auto',background:'linear-gradient(135deg,#C8962A,#E8B84B)',width:32,height:32,borderRadius:'50%',border:'none',cursor:'pointer',fontSize:20,color:'#060E16',fontWeight:700,display:'flex',alignItems:'center',justifyContent:'center'}}>+</button>
        </div>
        <div style={{display:'flex',gap:7,overflowX:'auto',paddingBottom:12}}>
          {FILTERS.map(f=>(
            <button key={f.id} onClick={()=>setFilter(f.id)} style={{padding:'5px 13px',borderRadius:20,fontSize:10.5,fontWeight:600,background:filter===f.id?'#C8962A':'rgba(255,255,255,0.06)',color:filter===f.id?'#060E16':'rgba(200,184,160,0.55)',border:filter===f.id?'none':'1px solid rgba(255,255,255,0.1)',cursor:'pointer',whiteSpace:'nowrap',fontFamily:'inherit'}}>{f.label}</button>
          ))}
        </div>
      </div>
      <div className="scroll-y" style={{flex:1,padding:'0 18px 24px'}}>
        {filtered.length===0&&<div style={{textAlign:'center',padding:'40px 0',color:'rgba(200,184,160,0.4)',fontSize:14}}>No tasks here.<br/><span style={{fontSize:12}}>Tap + to add one</span></div>}
        <div style={{display:'flex',flexDirection:'column',gap:8}}>
          {filtered.map(task=>{
            const ov=!task.isCompleted&&task.dueDate&&task.dueDate<today
            return(
              <div key={task.id} style={{background:task.isCompleted?'rgba(76,175,130,0.07)':ov?'rgba(232,133,90,0.08)':'rgba(255,255,255,0.045)',border:`1.5px solid ${task.isCompleted?'rgba(76,175,130,0.22)':ov?'rgba(232,133,90,0.38)':PBD[task.priority]||'rgba(255,255,255,0.1)'}`,borderRadius:14,padding:'11px 13px',display:'flex',alignItems:'flex-start',gap:10,opacity:task.isCompleted?0.72:1}}>
                <button onClick={()=>toggle(task)} style={{width:24,height:24,borderRadius:'50%',flexShrink:0,marginTop:1,border:`2px solid ${task.isCompleted?'#4CAF82':PC[task.priority]||'rgba(255,255,255,0.3)'}`,background:task.isCompleted?'rgba(76,175,130,0.25)':'transparent',cursor:'pointer',display:'flex',alignItems:'center',justifyContent:'center'}}>
                  {task.isCompleted&&<span style={{color:'#4CAF82',fontSize:12}}>✓</span>}
                </button>
                <div style={{flex:1,minWidth:0}}>
                  <div style={{fontSize:13,fontWeight:600,color:task.isCompleted?'rgba(200,184,160,0.45)':'#EEE8D5',textDecoration:task.isCompleted?'line-through':'none'}}>{task.title}</div>
                  <div style={{fontSize:10,color:ov?'#E8855A':'rgba(200,150,42,0.6)',marginTop:2}}>{ov?'⚠ Overdue':task.dueDate===today?'Today':task.dueDate} · {task.category}</div>
                  {task.notes?<div style={{fontSize:11,color:'rgba(200,184,160,0.4)',marginTop:3,overflow:'hidden',textOverflow:'ellipsis',whiteSpace:'nowrap'}}>{task.notes}</div>:null}
                </div>
                <div style={{display:'flex',flexDirection:'column',alignItems:'flex-end',gap:5,flexShrink:0}}>
                  {!task.isCompleted&&<div style={{background:PBG[task.priority],color:PC[task.priority],padding:'2px 8px',borderRadius:8,fontSize:9,fontWeight:700,textTransform:'uppercase'}}>{task.priority}</div>}
                  <button onClick={()=>db.tasks.delete(task.id)} style={{background:'none',border:'none',cursor:'pointer',color:'rgba(200,184,160,0.28)',fontSize:14,padding:2}}>✕</button>
                </div>
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )
}
