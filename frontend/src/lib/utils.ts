import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatDate(dateString: string): string {
  const date = new Date(dateString)
  return date.toLocaleDateString('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  })
}

export function formatDateTime(dateString: string): string {
  const date = new Date(dateString)
  return date.toLocaleString('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

export function getPositionColor(position: string): string {
  switch (position) {
    case 'P1': return 'bg-red-500 text-white'
    case 'P2': return 'bg-blue-500 text-white'
    case 'P3': return 'bg-green-500 text-white'
    case 'P4': return 'bg-yellow-500 text-black'
    case 'P5': return 'bg-purple-500 text-white'
    default: return 'bg-gray-500 text-white'
  }
}

export function getCategoryColor(category: string): string {
  switch (category) {
    case 'immortal': return 'bg-gradient-to-r from-yellow-400 to-orange-500 text-black'
    case 'ancient': return 'bg-gradient-to-r from-purple-400 to-blue-500 text-white'
    default: return 'bg-gray-500 text-white'
  }
}

export function getPositionName(position: string): string {
  switch (position) {
    case 'P1': return 'Hard Carry'
    case 'P2': return 'Mid'
    case 'P3': return 'Offlaner'
    case 'P4': return 'Support'
    case 'P5': return 'Hard Support'
    default: return position
  }
}