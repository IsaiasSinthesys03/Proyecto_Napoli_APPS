import { useEffect, useState } from "react";

interface TimerProps {
  startTime: string | Date;
}

// Función para calcular la diferencia de tiempo y formatearla
function getTimeDifference(start: Date) {
  const diff = new Date().getTime() - start.getTime();
  const seconds = Math.floor((diff / 1000) % 60);
  const minutes = Math.floor((diff / 1000 / 60) % 60);

  return {
    total: diff,
    minutes: minutes.toString().padStart(2, "0"),
    seconds: seconds.toString().padStart(2, "0"),
  };
}

export function Timer({ startTime }: TimerProps) {
  const startDate = new Date(startTime);
  const [time, setTime] = useState(getTimeDifference(startDate));

  useEffect(() => {
    const interval = setInterval(() => {
      setTime(getTimeDifference(startDate));
    }, 1000);

    // Limpiar el intervalo cuando el componente se desmonte
    return () => clearInterval(interval);
  }, [startDate]);

  return (
    <span className="font-mono text-sm">
      {time.minutes}:{time.seconds}
    </span>
  );
}
