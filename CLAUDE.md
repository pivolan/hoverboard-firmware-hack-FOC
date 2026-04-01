# Hoverboard FOC Firmware

## Build
- Ветка для сборки: `spd-120` (main сломан)
- Юзер для сборки: `claude`
- Тулчейн: `arm-none-eabi-gcc` (системный пакет)

```bash
# Make
su claude -c "cd /var/www/hoverboard-firmware-hack-FOC && make clean && make -e VARIANT=VARIANT_PWM"
# Выход: build/hover.bin

# PlatformIO
su claude -c "cd /var/www/hoverboard-firmware-hack-FOC && pio run"
# Выход: .pio/build/VARIANT_PWM/firmware.bin
```

## Git
- Автор: pivolan <pivolan@gmail.com>
- Push: grutapig не имеет прав на pivolan/hoverboard-firmware-hack-FOC — пушить не получится
- Git identity настроен локально в репо

## Telegram
Топик пользователя: chat `-1003866396190`, thread `1857`. Отправка через `telegram_send` (см. глобальный CLAUDE.md).

Прошивку переименовать перед отправкой: `cp build/hover.bin /tmp/<имя_по_формату>.bin`

## Именование файлов прошивки
Имя `.bin` файла при отправке должно отражать суть прошивки. Формат:
```
<ветка_кратко>_v<версия>_<поле>_<режим>_<лимит_об>_<рулевая>_<вход>_<доп>.bin
```
- **Ветка** — уникальное сокращение: `spd` для spd-120, `mpd` для moped-dual и т.д.
- **Версия** — инкрементный номер, увеличивать при каждой пересборке
- **Поле** — тип управления полем: `foc`, `sin`
- **Режим** — управление скоростью: `spd`, `trq`, `vlt`
- **Лимит оборотов** — числом, напр. `120`, `300`
- **Рулевая** — скорость/коэф. поворота, напр. `st6000`
- **Вход** — тип и сторона управления: `pwmR`, `pwmL`, `adcL`, `uartR`
- **Доп** — кратко что изменилось, если есть

Примеры:
- `mpd_v1_foc_spd_120_st6000_adcL_pwmR.bin`
- `spd_v41_foc_spd_120_st4000_pwmR_lowaccel.bin`

## Ветки
- `spd-120` — рабочая, билдится
- `moped-dual` — dual control (ADC + PWM), FOC+SPD без ограничения скорости, только отсечка тока
- `main` — сломан (MULTIPLE_TAP_* не определены)
