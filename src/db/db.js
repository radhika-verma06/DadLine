import Dexie from 'dexie'
export const db = new Dexie('PapaAppDB')
db.version(1).stores({
  tasks:'++id,title,dueDate,priority,category,isCompleted,completedAt,reminder,notes,createdAt',
  notes:'++id,title,body,colour,createdAt,updatedAt',
  routine:'++id,title,timeSlot,time,isCompleted,completedDate',
  progress:'++id,date,tasksCompleted,tasksTotal',
  settings:'key',
})
db.on('ready',async()=>{
  const c=await db.routine.count()
  if(c===0)await db.routine.bulkAdd([
    {title:'Morning walk',timeSlot:'morning',time:'07:00',isCompleted:false,completedDate:null},
    {title:'Breakfast + Meds',timeSlot:'morning',time:'08:00',isCompleted:false,completedDate:null},
    {title:'Read newspaper',timeSlot:'afternoon',time:'14:00',isCompleted:false,completedDate:null},
    {title:'Rest / Nap',timeSlot:'afternoon',time:'15:00',isCompleted:false,completedDate:null},
    {title:'Family call',timeSlot:'evening',time:'19:00',isCompleted:false,completedDate:null},
    {title:'Bedtime routine',timeSlot:'evening',time:'21:30',isCompleted:false,completedDate:null},
  ])
})
export const todayStr=()=>new Date().toISOString().split('T')[0]
export async function getStreak(){
  const records=await db.progress.orderBy('date').reverse().limit(60).toArray()
  if(!records.length)return 0
  let streak=0,check=new Date();check.setHours(0,0,0,0)
  for(const r of records){const d=new Date(r.date);d.setHours(0,0,0,0);if(d.getTime()===check.getTime()&&r.tasksCompleted>0){streak++;check.setDate(check.getDate()-1)}else break}
  return streak
}
export async function getSetting(key,fallback=null){const row=await db.settings.get(key);return row?row.value:fallback}
export async function setSetting(key,value){await db.settings.put({key,value})}
