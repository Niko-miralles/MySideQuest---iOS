import SwiftUI

// Racha: días consecutivos completando al menos una misión
struct StreakView: View {
    @Environment(GameStore.self) private var store

    struct WeekDay: Identifiable {
        let date: Date
        let done: Bool
        let isToday: Bool
        var id: TimeInterval { date.timeIntervalSince1970 }
    }

    private var weekDays: [WeekDay] {
        let cal = Calendar.current
        let doneDays = Set((store.player?.completions ?? []).map { cal.startOfDay(for: $0.date) })
        let today = cal.startOfDay(for: .now)
        return (0..<7).compactMap { back -> WeekDay? in
            guard let d = cal.date(byAdding: .day, value: -back, to: today) else { return nil }
            return WeekDay(date: d, done: doneDays.contains(d), isToday: back == 0)
        }.reversed()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.white, SQ.lav], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("\(store.streak)")
                            .font(.px(56))
                            .foregroundStyle(SQ.gold)
                        Text(store.streak == 1 ? "día de racha" : "días de racha")
                            .font(.fredoka(18, weight: .semibold))
                            .foregroundStyle(SQ.muted)
                        Image(systemName: "flame.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(store.streak > 0 ? SQ.gold : SQ.line)
                    }
                    .padding(.top, 40)

                    // semana actual
                    HStack(spacing: 10) {
                        ForEach(weekDays) { day in
                            VStack(spacing: 6) {
                                Text(day.date, format: .dateTime.weekday(.narrow))
                                    .font(.fredoka(12, weight: .semibold))
                                    .foregroundStyle(SQ.muted)
                                ZStack {
                                    Circle()
                                        .fill(day.done ? SQ.gold : .white)
                                        .overlay(Circle().stroke(
                                            day.isToday ? SQ.violet : SQ.line,
                                            lineWidth: day.isToday ? 2 : 1))
                                        .frame(width: 38, height: 38)
                                    if day.done {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(SQ.goldInk)
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .sqCard()

                    Text(store.completedToday()
                         ? "Misión de hoy completada. ¡Racha a salvo!"
                         : "Completa una misión hoy para mantener la racha.")
                        .font(.fredoka(15))
                        .foregroundStyle(SQ.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Racha")
        }
    }
}
