# Buckets

The boundaries were developed from researching a lot of different devices' virtual display sizes as seen by a web browser.

---

## Width buckets

Because width plays a much larger role in web interface responsiveness than height, Width buckets have two different levels of fineness.

### Broad

| display bucket | min width | max width | analogues |
|---|--|--|--|
| handset | none | 511px | Handheld devices (ie. phones) |
| portable | 512px | 1055px | Most tablet contexts |
| wide | 1056px | none | Large landscape tablet, laptop, desktop, or TV contexts.  |


### Fine

These buckets are sub-levels of the broad buckets and can help you understand more clearly the user's ergonomic context.

| display bucket | min width | max width | analogues |
|---|--|--|--|
| handset1 | none | 351px | Small devices that can be held in one hand, and are entirely operable with one hand. |
| handset2 | 352px | 383px | Medium devices that can be held in one hand, and are mostly (but not completly) operable with one hand. |
| handset3 | 384px | 511px | Large devices that can be held in one hand, but are not entirely operable with one hand. |
| portable1 | 512px | 639px | Small tablets. Narrow desktop windows. |
| portable2 | 640px | 863px | Regular tablets (ie. iPad 9.7") in portrait, Small desktop windows. |
| portable3 | 864px | 1055px | Large tablets in portrait. Small and regular tablets in landscape. 1024x768. |
| wide1 | 1056px | 1439px | Large tablets in landscape and laptops. 720p, 1366x768, 1280x800.  |
| wide2 | 1440px | none | Desktop and other large displays. 1680x1050, 1080p/4K. |



## Height buckets

These correspond to handset, portable1 and portable3 respectively but in height, not width.

| display bucket | min height | max height | analogues |
|---|--|--|--|
| limited | none | 511px | Handheld devices (ie. phones) in landscape. The amount of vertical space is very limited. |
| medium | 512px | 863px | Small and regular tablets in landscape. The amount of vertical space is restricted. |
| tall | 864px | none | Large landscape tablet, laptop or desktop contexts. The amount of vertical space is generally ample. |



---

## Device examples

Here are how the width buckets map out to specific devices.

##### handset1
Typically devices below 4.7".

| Device(s) | Viewport resolution (portrait) |
| -- | -- |
| Apple iPhone 1-3G | 320 x 480 (@1x) |
| Apple iPhone 4, 4S | 320 x 480 (@2x) |
| Apple iPhone 5, 5c, 5s, SE (1st gen) | 320 x 568 (@2x) |

##### handset2
Typically devices between 4.7 and ~6"

| Device(s) | Viewport resolution (portrait) |
| -- | -- |
| Apple iPhone 12 Mini | 360 x 780 (@3x) |
| Sony Xperia XZ2 Compact | 360 x 720 |
| Apple iPhone 6-8, SE (2nd gen) | 375 x 687 |
| Apple iPhone X, XS, 11 Pro | 375 x 812 |

##### handset3
Typically devices between ~6 and 7".

| Device(s) | Viewport resolution (portrait) |
| -- | -- |
| Google Pixel XL | 412 x 732 |
| Apple iPhone 6-8 Plus | 414 x 736 |
| Google Pixel 3 | 411 x 823 (@2.625x) |
| Google Pixel 3 XL | 411 x 846 (@3x) |
| Apple iPhone XR, XS Max, 11, 11 Pro Max | 414 x 896 |
| Samsung Galaxy S9+, Google Pixel 3 XL | 411 x 846 |
| Sony Xperia 1 | 411 x 960 (@4x) |


##### portable1
Devices between 7 - 8". This is generally quite an archaic device format nowadays, but this bucket also aligns with narrow tablet and desktop windows.

| Device(s) | Viewport resolution (portrait) |
| -- | -- |
| Google Nexus 7 (2013) | 600 x 960 (@3x) |


##### portable2
Devices between 8 - 10".

| Device(s) | Viewport resolution (portrait) |
| -- | -- |
| Apple iPad 9.7", mini | 768 x 1024 |
| Apple iPad 10.2" | 810 x 1080 |
| Apple iPad Pro (2015-2017) 10.5" | 834 x 1112 |
| Apple iPad Pro (2018) 11" | 834 x 1194 |
| Google Nexus 10 | 800 x 1280 |
| Google Pixel C | 900 x 1280 |


##### portable3
Portable devices larger than 10".

| Device(s) | Viewport resolution (portrait) |
| -- | -- |
| Apple iPad Pro (2015-2017, 2018) 12.9" | 1024 x 1366 |
| Microsoft Surface Pro 2017 | 912 x 1368 |

---
