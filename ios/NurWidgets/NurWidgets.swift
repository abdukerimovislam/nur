import WidgetKit
import SwiftUI

struct NurWidgetEntry: TimelineEntry {
    let date: Date
    let nextPrayerName: String
    let nextPrayerTime: String
    let nextPrayerDate: Date?
    let timeRemaining: String
    let city: String
    let streak: Int
    let todayProgressPercent: Int
    let ayahText: String
    let ayahReference: String
    let duaText: String
}

struct NurWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> NurWidgetEntry {
        NurWidgetEntry.preview
    }

    func getSnapshot(in context: Context, completion: @escaping (NurWidgetEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NurWidgetEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadEntry() -> NurWidgetEntry {
        let defaults = UserDefaults(suiteName: NurWidgetConstants.appGroupId)
        let nextPrayerTimestamp = defaults?.double(forKey: "nextPrayerTimestamp") ?? 0
        let nextPrayerDate = nextPrayerTimestamp > 0
            ? Date(timeIntervalSince1970: nextPrayerTimestamp / 1000)
            : nil

        return NurWidgetEntry(
            date: Date(),
            nextPrayerName: defaults?.string(forKey: "nextPrayerName") ?? "Prayer",
            nextPrayerTime: defaults?.string(forKey: "nextPrayerTime") ?? "--:--",
            nextPrayerDate: nextPrayerDate,
            timeRemaining: defaults?.string(forKey: "timeRemaining") ?? "--:--",
            city: defaults?.string(forKey: "city") ?? "Nur Islam Hub",
            streak: defaults?.integer(forKey: "streak") ?? 0,
            todayProgressPercent: defaults?.integer(forKey: "todayProgressPercent") ?? 0,
            ayahText: defaults?.string(forKey: "ayahText") ?? "So remember Me; I will remember you.",
            ayahReference: defaults?.string(forKey: "ayahReference") ?? "Quran 2:152",
            duaText: defaults?.string(forKey: "duaText") ?? "O Allah, guide my heart and make prayer beloved to me."
        )
    }
}

private enum NurWidgetConstants {
    static let appGroupId = "group.com.nur.widgets"
    static let backgroundStart = Color(red: 0.02, green: 0.10, blue: 0.09)
    static let backgroundEnd = Color(red: 0.10, green: 0.13, blue: 0.10)
    static let surface = Color.white.opacity(0.10)
    static let border = Color.white.opacity(0.16)
    static let gold = Color(red: 0.93, green: 0.78, blue: 0.38)
    static let mint = Color(red: 0.43, green: 0.82, blue: 0.66)
    static let textSoft = Color.white.opacity(0.72)
}

private extension NurWidgetEntry {
    static let preview = NurWidgetEntry(
        date: Date(),
        nextPrayerName: "Asr",
        nextPrayerTime: "16:42",
        nextPrayerDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date()),
        timeRemaining: "02:14",
        city: "Bishkek",
        streak: 7,
        todayProgressPercent: 60,
        ayahText: "So remember Me; I will remember you.",
        ayahReference: "Quran 2:152",
        duaText: "O Allah, guide my heart and make prayer beloved to me."
    )
}

private struct NurWidgetBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                NurWidgetConstants.backgroundStart,
                Color(red: 0.06, green: 0.17, blue: 0.14),
                NurWidgetConstants.backgroundEnd
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(NurWidgetConstants.gold.opacity(0.12))
                .frame(width: 120, height: 120)
                .blur(radius: 18)
                .offset(x: 42, y: -46)
        }
    }
}

private struct NurWidgetBadge: View {
    let text: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.system(size: 10, weight: .bold))
            Text(text)
                .font(.system(size: 10, weight: .black))
                .tracking(0.8)
        }
        .foregroundColor(NurWidgetConstants.gold)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(NurWidgetConstants.surface)
        .clipShape(Capsule())
        .overlay {
            Capsule().stroke(NurWidgetConstants.border, lineWidth: 1)
        }
    }
}

private struct PrayerCountdownText: View {
    let entry: NurWidgetEntry
    let fontSize: CGFloat

    var body: some View {
        if let date = entry.nextPrayerDate, date > Date() {
            Text(date, style: .timer)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .monospacedDigit()
        } else {
            Text(entry.timeRemaining)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
    }
}

struct NurPrayerWidgetView: View {
    let entry: NurWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            circularLockWidget
        case .accessoryRectangular:
            rectangularLockWidget
        case .accessoryInline:
            Text("Nur Islam Hub - \(entry.nextPrayerName) \(entry.nextPrayerTime)")
        case .systemMedium:
            mediumHomeWidget
        default:
            smallHomeWidget
        }
    }

    private var circularLockWidget: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 15, weight: .semibold))
                Text(entry.nextPrayerName.prefix(4))
                    .font(.system(size: 11, weight: .bold))
                PrayerCountdownText(entry: entry, fontSize: 10)
            }
        }
    }

    private var rectangularLockWidget: some View {
        HStack(spacing: 8) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 18, weight: .semibold))
            VStack(alignment: .leading, spacing: 2) {
                Text("Next: \(entry.nextPrayerName)")
                    .font(.system(size: 14, weight: .bold))
                HStack(spacing: 4) {
                    PrayerCountdownText(entry: entry, fontSize: 12)
                    Text("left - \(entry.todayProgressPercent)% today")
                        .font(.system(size: 12, weight: .medium))
                }
            }
        }
    }

    private var smallHomeWidget: some View {
        ZStack {
            NurWidgetBackground()
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    NurWidgetBadge(text: "NUR HUB", systemImage: "sparkles")
                    Spacer()
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(NurWidgetConstants.gold)
                }

                Spacer()

                Text("Next prayer")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(NurWidgetConstants.textSoft)

                Text(entry.nextPrayerName)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                HStack(spacing: 7) {
                    PrayerCountdownText(entry: entry, fontSize: 16)
                    Text("left")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(NurWidgetConstants.textSoft)
                }
                    .foregroundColor(NurWidgetConstants.gold)

                ProgressView(value: Double(entry.todayProgressPercent), total: 100)
                    .tint(NurWidgetConstants.mint)
                    .scaleEffect(x: 1, y: 0.65, anchor: .center)
            }
            .padding(16)
        }
    }

    private var mediumHomeWidget: some View {
        ZStack {
            NurWidgetBackground()
            HStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 9) {
                    NurWidgetBadge(text: "NUR ISLAM HUB", systemImage: "sparkles")

                    Text(entry.nextPrayerName)
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.system(size: 14, weight: .bold))
                        PrayerCountdownText(entry: entry, fontSize: 18)
                    }
                    .foregroundColor(NurWidgetConstants.gold)

                    Text(entry.city)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(NurWidgetConstants.textSoft)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(entry.streak)")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("day streak")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(NurWidgetConstants.textSoft)

                    Text("\(entry.todayProgressPercent)% today")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(NurWidgetConstants.mint)
                }
            }
            .padding(18)
        }
    }
}

struct NurAyahWidgetView: View {
    let entry: NurWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.ayahText)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(2)
                Text(entry.ayahReference)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        case .accessoryInline:
            Text("\(entry.ayahReference): \(entry.ayahText)")
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 2) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Ayah")
                        .font(.system(size: 11, weight: .bold))
                }
            }
        default:
            ZStack {
                NurWidgetBackground()
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        NurWidgetBadge(text: "QURAN", systemImage: "book.closed.fill")
                        Spacer()
                        Image(systemName: "quote.opening")
                            .foregroundColor(NurWidgetConstants.gold)
                    }

                    Spacer()

                    Text(entry.ayahText)
                        .font(.system(size: family == .systemMedium ? 25 : 19, weight: .black, design: .serif))
                        .foregroundColor(.white)
                        .lineLimit(family == .systemMedium ? 3 : 4)
                        .minimumScaleFactor(0.72)

                    Text(entry.ayahReference)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(NurWidgetConstants.gold)
                }
                .padding(16)
            }
        }
    }
}

struct NurDuaWidgetView: View {
    let entry: NurWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            HStack(spacing: 7) {
                Image(systemName: "heart.fill")
                Text(entry.duaText)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(2)
            }
        case .accessoryInline:
            Text("Nur dua - \(entry.duaText)")
        default:
            ZStack {
                NurWidgetBackground()
                VStack(alignment: .leading, spacing: 9) {
                    HStack {
                        NurWidgetBadge(text: "DAILY DUA", systemImage: "hand.raised.fill")
                        Spacer()
                        Image(systemName: "heart.fill")
                            .foregroundColor(NurWidgetConstants.gold)
                    }

                    Spacer()

                    Text(entry.duaText)
                        .font(.system(size: family == .systemMedium ? 23 : 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(family == .systemMedium ? 3 : 4)
                        .minimumScaleFactor(0.72)
                }
                .padding(16)
            }
        }
    }
}

struct NurStreakWidgetView: View {
    let entry: NurWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 1) {
                    Text("\(entry.streak)")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                    Text("days")
                        .font(.system(size: 10, weight: .bold))
                }
            }
        case .accessoryRectangular:
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entry.streak) day streak")
                        .font(.system(size: 14, weight: .bold))
                    Text("\(entry.todayProgressPercent)% completed today")
                        .font(.system(size: 12, weight: .medium))
                }
            }
        case .accessoryInline:
            Text("Nur streak \(entry.streak)d")
        default:
            ZStack {
                NurWidgetBackground()
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        NurWidgetBadge(text: "PRAYER STREAK", systemImage: "checkmark.seal.fill")
                        Spacer()
                        Image(systemName: "flame.fill")
                            .foregroundColor(NurWidgetConstants.gold)
                    }

                    Spacer()

                    Text("\(entry.streak)")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("days of completed prayers")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(NurWidgetConstants.textSoft)
                }
                .padding(16)
            }
        }
    }
}

struct NurPrayerWidget: Widget {
    let kind = "NurWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NurWidgetProvider()) { entry in
            NurPrayerWidgetView(entry: entry)
        }
        .configurationDisplayName("Nur Islam Prayer")
        .description("Next prayer, countdown, streak and progress.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

struct NurAyahWidget: Widget {
    let kind = "NurAyahWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NurWidgetProvider()) { entry in
            NurAyahWidgetView(entry: entry)
        }
        .configurationDisplayName("Nur Islam Ayah")
        .description("A Quran reminder for the Home Screen and Lock Screen.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

struct NurDuaWidget: Widget {
    let kind = "NurDuaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NurWidgetProvider()) { entry in
            NurDuaWidgetView(entry: entry)
        }
        .configurationDisplayName("Nur Islam Dua")
        .description("Daily dua reminders.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

struct NurStreakWidget: Widget {
    let kind = "NurStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NurWidgetProvider()) { entry in
            NurStreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Nur Islam Streak")
        .description("Prayer streak and daily progress.")
        .supportedFamilies([
            .systemSmall,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
