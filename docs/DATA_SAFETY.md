# Google Play – Data safety form

Play Console › your app › **Policy › App content › Data safety** › *Start*.
Answers below match what the app really does: no accounts, progress stored only on the device,
ads by **Google AdMob**, purchases by **Google Play Billing**, local notifications only.
Data handled by SDKs inside the app (AdMob, Play Billing) counts as collected by the app.

## Step 1 – Overview
Read and continue.

## Step 2 – Data collection and security

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **Yes** |
| Is all of the user data collected by your app encrypted in transit? | **Yes** (all SDKs use HTTPS) |
| Which methods of account creation does your app support? | **My app does not allow users to create an account** |
| Do you provide a way for users to request that their data is deleted? | **No** — the app has no server or account; game data lives on the device and is removed on uninstall. Ad data is controlled by the user's device ad settings / Google. |

## Step 3 – Data types (tick exactly these)

| Category | Data type | Tick |
|---|---|---|
| **Location** | Approximate location | ✅ (AdMob derives it from the IP address) |
| **Financial info** | Purchase history | ✅ (in-app purchases via Google Play) |
| **App activity** | App interactions | ✅ (AdMob: ad views, taps, app launches) |
| **App info and performance** | Diagnostics | ✅ (AdMob: ad performance / SDK diagnostics) |
| **Device or other IDs** | Device or other IDs | ✅ (advertising ID, app set ID) |

Leave everything else **unticked**: Personal info (name, e-mail, …), Precise location, Messages, Photos
and videos, Audio, Files and docs, Calendar, Contacts, Web browsing, Health and fitness, Credit card /
financial details, Crash logs, Search history, Installed apps, Other user-generated content.

## Step 4 – Data usage and handling (one form per ticked type)

### Approximate location
| Question | Answer |
|---|---|
| Collected / Shared | **Collected ✅  Shared ✅** |
| Processed ephemerally? | **No** |
| Required or optional? | **Data collection is required** (users can't turn it off in the app) |
| Why collected? | **Advertising or marketing**, **Analytics**, **Fraud prevention, security, and compliance** |
| Why shared? | **Advertising or marketing**, **Analytics**, **Fraud prevention, security, and compliance** |

### App interactions
Same answers as *Approximate location* (Collected + Shared, not ephemeral, required,
purposes: Advertising or marketing, Analytics, Fraud prevention, security, and compliance).

### Diagnostics
| Question | Answer |
|---|---|
| Collected / Shared | **Collected ✅  Shared ✅** |
| Processed ephemerally? | **No** |
| Required or optional? | **Required** |
| Why collected / shared? | **Analytics**, **Fraud prevention, security, and compliance** |

### Device or other IDs
| Question | Answer |
|---|---|
| Collected / Shared | **Collected ✅  Shared ✅** |
| Processed ephemerally? | **No** |
| Required or optional? | **Required** |
| Why collected / shared? | **Advertising or marketing**, **Analytics**, **Fraud prevention, security, and compliance** |

### Purchase history
| Question | Answer |
|---|---|
| Collected / Shared | **Collected ✅  Shared ☐** (handled by Google Play, not passed to other companies) |
| Processed ephemerally? | **No** |
| Required or optional? | **Optional** — only when the user makes a purchase |
| Why collected? | **App functionality** (unlock Remove Ads / VIP / hints, restore purchases) |

## Step 5 – Preview and submit
Check the summary shows: *Data shared with third parties: Location, App activity, App info and
performance, Device or other IDs* · *Data collected: the same + Financial info* · *Data is encrypted in
transit* · *You can't request that data be deleted*. Then **Save** › **Submit**.

## Related App content sections (must match)
| Section | Answer |
|---|---|
| **Advertising ID** | **Yes** — uses: Advertising or marketing, Analytics, Fraud prevention, security, and compliance (the manifest declares `AD_ID`) |
| **Ads** | **Yes, my app contains ads** |
| **Privacy policy** | `https://shaileshpatel008.github.io/CrossMathPuzzleGame/privacy-policy.html` (describes the same data) |
| **Target audience** | 13+ (keeps the app out of the Families policy; the form above assumes this) |

## Keep it in sync
Update this form whenever you add an SDK — e.g. Firebase Analytics/Crashlytics would add
*Crash logs* and change Analytics answers; a login would add *Personal info* and require a
data-deletion option.
