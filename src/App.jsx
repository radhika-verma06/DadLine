import { useState, useEffect } from 'react'
import { getSetting } from './db/db'
import TabBar        from './components/TabBar'
import Splash        from './screens/Splash'
import Onboarding    from './screens/Onboarding'
import BirthdaySetup from './screens/BirthdaySetup'
import Home          from './screens/Home'
import Tasks         from './screens/Tasks'
import Routine       from './screens/Routine'
import Notes         from './screens/Notes'
import Progress      from './screens/Progress'
import Birthday      from './screens/Birthday'
import { useBirthday } from './hooks/useBirthday'

export default function App() {
  const [phase,    setPhase]    = useState('splash')
  const [tab,      setTab]      = useState('home')
  const [userName, setUserName] = useState('Papa')

  const { isBirthday, showBirthday, userName: bdName, dismiss, trigger } = useBirthday()

  useEffect(() => {
    getSetting('onboarded').then(v => { if (v) setPhase('app') })
  }, [])

  function afterSplash() {
    getSetting('onboarded').then(v => setPhase(v ? 'app' : 'onboard'))
  }

  function afterOnboard(name) {
    setUserName(name)
    setPhase('birthday-setup')
  }

  function afterBirthdaySetup() {
    setPhase('app')
  }

  const SCREENS = {
    home:     <Home onNav={setTab} />,
    tasks:    <Tasks />,
    routine:  <Routine />,
    notes:    <Notes />,
    progress: <Progress />,
  }

  return (
    <div style={{ display:'flex', flexDirection:'column', height:'100%', background:'#060E16', overflow:'hidden' }}>
      {phase === 'splash'         && <Splash         onDone={afterSplash} />}
      {phase === 'onboard'        && <Onboarding     onDone={afterOnboard} />}
      {phase === 'birthday-setup' && <BirthdaySetup  name={userName} onDone={afterBirthdaySetup} />}

      {phase === 'app' && (
        <>
          <div style={{ flex:1, overflow:'hidden', position:'relative' }}>
            {SCREENS[tab]}
          </div>
          <TabBar active={tab} onChange={setTab} />

          {/* Floating birthday button on their birthday */}
          {isBirthday && !showBirthday && (
            <button onClick={trigger} style={{
              position:'fixed', bottom:88, right:18, zIndex:100,
              background:'linear-gradient(135deg,#C8962A,#E8B84B)',
              border:'none', borderRadius:'50%', width:58, height:58,
              fontSize:28, cursor:'pointer',
              boxShadow:'0 0 28px rgba(200,150,42,0.6)',
              animation:'ring-pulse 2s ease-in-out infinite',
            }}>🎂</button>
          )}
        </>
      )}

      {/* Birthday overlay */}
      {showBirthday && (
        <Birthday name={bdName || userName} onClose={dismiss} />
      )}
    </div>
  )
}
