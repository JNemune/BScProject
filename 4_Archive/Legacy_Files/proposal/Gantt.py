import matplotlib.pyplot as plt
from matplotlib.font_manager import FontProperties
import jdatetime
from bidi.algorithm import get_display
import arabic_reshaper


# تابع کمکی برای نمایش درست حروف فارسی در Matplotlib
def pt(text):
    reshaped_text = arabic_reshaper.reshape(text)
    return get_display(reshaped_text)


# تعریف فونت میترا (مطمئن شوید فونت B Mitra روی سیستم نصب است)
# اگر نام فونت در سیستم شما دقیقاً Mitra است، کلمه B Mitra را تغییر دهید
mitra_font = FontProperties(family="B Mitra", size=12)
title_font = FontProperties(family="B Mitra", size=15)
legend_font = FontProperties(family="B Mitra", size=11)

# تعریف تاریخ مبدا برای تبدیل تاریخ‌ها به عدد (جهت رسم روی محور X) - اول خرداد در نظر گرفته شده است
base_date = jdatetime.date(1405, 3, 1)


def date_to_days(j_date):
    return (j_date - base_date).days


# تعریف وظایف پروژه بر اساس رویکرد شبیه‌سازی و کنترل بهینه (بازه دو ماهه)
tasks = [
    {
        "name": "۱. استخراج معادلات فضای حالت",
        "start": jdatetime.date(1405, 3, 16),
        "end": jdatetime.date(1405, 3, 25),
    },
    {
        "name": "۲. طراحی و تنظیم کنترل‌کننده $LQR$",
        "start": jdatetime.date(1405, 3, 26),
        "end": jdatetime.date(1405, 4, 5),
    },
    {
        "name": "۳. توسعه مدل شبیه‌سازی متلب",
        "start": jdatetime.date(1405, 4, 6),
        "end": jdatetime.date(1405, 4, 20),
    },
    {
        "name": "۴. ارزیابی عملکرد و استخراج نتایج",
        "start": jdatetime.date(1405, 4, 21),
        "end": jdatetime.date(1405, 5, 5),
    },
    {
        "name": "۵. تحلیل داده‌ها و نگارش پایان‌نامه",
        # شروع همزمان با روزهای پایانی تست‌ها جهت تسریع در تدوین گزارش
        "start": jdatetime.date(1405, 5, 1),
        "end": jdatetime.date(1405, 5, 20),
    },
]

fig, ax = plt.subplots(figsize=(12, 6))

# رسم میله‌های گانت چارت
y_ticks = []
y_labels = []
for i, task in enumerate(reversed(tasks)):
    start_day = date_to_days(task["start"])
    duration = date_to_days(task["end"]) - start_day
    # استفاده از رنگ سرمه‌ای مهندسی برای میله‌ها
    ax.barh(i, duration, left=start_day, color="#2C3E50", edgecolor="black", height=0.5)
    y_ticks.append(i)
    y_labels.append(pt(task["name"]))

ax.set_yticks(y_ticks)
ax.set_yticklabels(y_labels, fontproperties=mitra_font)

# --- اضافه کردن بازه اجرای پروژه به عنوان پس‌زمینه ---
project_start = date_to_days(jdatetime.date(1405, 3, 16))
project_end = date_to_days(jdatetime.date(1405, 5, 20))
ax.axvspan(
    project_start,
    project_end,
    color="#E8F8F5",
    alpha=0.6,
    label=pt("بازه اجرایی پروژه (دو ماه)"),
)

# --- تنظیمات محور X ---
x_ticks_days = [
    date_to_days(jdatetime.date(1405, 3, 16)),
    date_to_days(jdatetime.date(1405, 4, 1)),
    date_to_days(jdatetime.date(1405, 4, 15)),
    date_to_days(jdatetime.date(1405, 5, 1)),
    date_to_days(jdatetime.date(1405, 5, 20)),
]
x_tick_labels = [
    pt("۱۶ خرداد"),
    pt("۱ تیر"),
    pt("۱۵ تیر"),
    pt("۱ مرداد"),
    pt("۲۰ مرداد"),
]

ax.set_xticks(x_ticks_days)
ax.set_xticklabels(x_tick_labels, fontproperties=mitra_font)

plt.title(
    pt("گانت چارت زمان‌بندی پروژه (فاز شبیه‌سازی و کنترل بهینه)"),
    fontproperties=title_font,
    pad=20,
)
plt.xlabel(pt("زمان"), fontproperties=mitra_font)

# تنظیم فونت برای راهنمای نمودار (Legend)
# legend = plt.legend(loc="lower right")
# for text in legend.get_texts():
#     text.set_fontproperties(legend_font)

plt.grid(axis="x", linestyle="--", alpha=0.7)
plt.tight_layout()

# ذخیره تصویر با کیفیت بالا
plt.savefig("Gantt_Chart_Project.png", dpi=300)
plt.show()
