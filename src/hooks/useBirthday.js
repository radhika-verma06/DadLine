import { useEffect, useState, useCallback } from 'react'
import { getSetting, setSetting } from '../db/db'

export function useBirthday() {
  const [isBirthday,   setIsBirthday]   = useState(false)
  const [showBirthday, setShowBirthday] = useState(false)
  const [userName,     setUserName]     = useState('Papa')

  const check = useCallback(async () => {
    const dobDay   = await getSetting('dobDay')
    const dobMonth = await getSetting('dobMonth')
    const name     = await getSetting('userName', 'Papa')
    setUserName(name)
    if (!dobDay || !dobMonth) return
    const now  = new Date()
    const isBD = now.getDate() === dobDay && (now.getMonth() + 1) === dobMonth
    setIsBirthday(isBD)
    if (isBD) {
      const lastShown = await getSetting('bdLastShown')
      if (!lastShown || Date.now() - lastShown > 2 * 60 * 60 * 1000) {
        setShowBirthday(true)
        await setSetting('bdLastShown', Date.now())
      }
    }
  }, [])

  useEffect(() => { check() }, [check])

  useEffect(() => {
    if (!isBirthday) return
    schedulePushNotifications()
    const iv = setInterval(async () => {
      const last = await getSetting('bdLastShown')
      if (!last || Date.now() - last > 2 * 60 * 60 * 1000) {
        setShowBirthday(true)
        await setSetting('bdLastShown', Date.now())
      }
    }, 60 * 1000)
    return () => clearInterval(iv)
  }, [isBirthday])

  async function schedulePushNotifications() {
    if (!('Notification' in window)) return
    let perm = Notification.permission
    if (perm === 'default') perm = await Notification.requestPermission()
    if (perm !== 'granted') return
    const msgs = [
      '🎂 Happy Birthday Paji! Wishing you a wonderful day!',
      '🎉 Many many happy returns of the day, Paji!',
      '🌟 You are so loved and celebrated today!',
      '🥳 Hope your birthday is full of joy and laughter!',
      '🎈 Sending birthday love your way, Paji! 💛',
    ]
    ;[0, 7200000, 14400000, 21600000, 28800000].forEach((ms, i) => {
      setTimeout(() => {
        try {
          new Notification('🎂 Papa App', {
            body: msgs[i % msgs.length],
            icon: '/icon.png',
            tag: `bd-${i}`,
          })
        } catch(e) {}
      }, ms + 800)
    })
  }

  const dismiss = useCallback(() => setShowBirthday(false), [])
  const trigger  = useCallback(async () => {
    await setSetting('bdLastShown', Date.now())
    setShowBirthday(true)
  }, [])

  return { isBirthday, showBirthday, userName, dismiss, trigger }
}
