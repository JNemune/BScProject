from pathlib import Path

def merge_m_files(output_file: str = "merged_m_files.txt"):
    # دایرکتوری جاری که اسکریپت در آن اجرا شده است
    base_dir = Path.cwd()
    output_path = base_dir / output_file

    # جستجوی بازگشتی تمام فایل‌های .m
    m_files = sorted(base_dir.rglob("*.m"))

    total_files = 0

    with open(output_path, "w", encoding="utf-8") as outfile:
        for file_path in m_files:
            # جلوگیری از پردازش خود فایل خروجی (در صورتی که پسوند آن .m باشد)
            if file_path.resolve() == output_path.resolve():
                continue 
            # دریافت مسیر نسبی نسبت به محل اجرای برنامه
            relative_path = file_path.relative_to(base_dir)

            try:
                content = file_path.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                # مدیریت فایل‌هایی که انکودینگی غیر از UTF-8 دارند
                content = file_path.read_text(encoding="utf-8", errors="replace")

            # نوشتن جداکننده، آدرس فایل و محتوا
            separator = "=" * 70
            header = f"\n{separator}\nFILE: {relative_path.as_posix()}\n{separator}\n\n"
            
            outfile.write(header)
            outfile.write(content)
            outfile.write("\n")
            total_files += 1

    print(f"تعداد {total_files} فایل .m پردازش شد و در '{output_file}' ذخیره گردید.")

if __name__ == "__main__":
    merge_m_files()