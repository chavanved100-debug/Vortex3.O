# LearnLoop AI — Demo Script

Target length: **3 to 4 minutes**. Have the app already running
(`flutter run -d chrome`) and start on the Home screen.

Tip: widen the window or use a phone-sized frame so the layout looks intended.
Everything below works offline; turn off Wi-Fi if you want to prove it.

---

## 0. Framing (15s, no taps)

> "Most apps tell a learner they're wrong and move on. LearnLoop AI treats a
> wrong answer as a clue. It diagnoses *why* you got it wrong, then adapts the
> next step — fully offline, and honest about what it actually knows."

---

## 1. Learn the concept (30s)

1. Tap **Mathematics**.
2. Tap **Algebra**.
3. Tap **Linear Equations**.
4. Scroll the lesson: objective, explanation, the **Worked example**, and
   collapsed **Hints**.

> "Every lesson ships offline: the concept, a worked example, and graded hints."

5. Tap **Start quiz** (bottom of the screen).

---

## 2. The wrong answer that starts the investigation (45s)

1. On "Solve for x: 2x - 3 = 7", select **x = 2**.
2. Tap **Submit answer**.
3. Point at the feedback: **Not quite**, your answer, the verified answer, and
   the explanation.
4. Tap **Open the Detective**.

> "This is the Wrong Answer Detective. Watch how carefully it separates what it
> knows from what it suspects."

On the Detective screen, highlight:

- **Certain:** the answer differs from the verified answer.
- **Likely cause / Pattern:** "Sign or direction error" — an *inference*, not
  proof.
- **Evidence** list and the **Confidence** bar.
- The **Targeted hint**.

5. Tap **See the suggested next step**.

---

## 3. Adaptive follow-up (30s)

On the **Your next step** screen:

- Activity: **A worked example** (chosen for a sign error).
- The explanation and the **Your next question** card.
- Tap **Start this question** to show the follow-up opens in the same topic.

> "The next question isn't random. It's chosen from the diagnosis and the
> learner's own follow-up chain, and the topic context is preserved."

(Optional: go back and show that a *conceptual* mistake instead produces a
**simpler explanation** plus targeted practice — different cause, different
response.)

---

## 4. The correct path and cautious mastery (30s)

1. Return Home, reopen **Linear Equations → Start quiz**.
2. Choose **x = 5**, **Submit answer**, then **See suggested next step**.

> "For a correct answer it does not declare victory."

Point at **A more challenging question** and the note:

> "One correct answer is progress, not proof of mastery. A few more will tell us
> more."

---

## 5. Uncertainty is handled honestly (30s)

1. From Home, go to **Python → Loops and Range → Start quiz**.
2. Pick an answer that doesn't match a known pattern (for example **1 2 3** maps
   to a boundary error — use a mixed choice if you want the uncertain path).
3. If the diagnosis is not confident, the app shows **One quick clarification
   first** and asks a short question instead of guessing.

> "When it can't tell, it asks — it never dresses up a guess as a fact."

---

## 6. Progress dashboard (30s)

1. Return Home and tap the **insights icon** (top-right).
2. Show: Attempted / Correct / Incorrect / Accuracy, **Topic progress** with
   cautious mastery chips, **Repeated misconception categories**, **Topics
   needing revision**, and **Recent learning sessions**.
3. Point at the **Offline-first** banner.

> "Progress is stored locally on this device. Repeated misconceptions surface on
> their own — the app learns this learner's patterns over time."

If a pre/post comparison is present, note the sample size and the causality
disclaimer.

---

## 7. Close (15s)

> "Offline-first, honest about uncertainty, and it adapts to the *reason* a
> learner struggled — not just the score. That's LearnLoop AI: the Wrong Answer
> Detective."

---

## Backup talking points

- **Missing content is graceful.** Open a topic like *Calculus → Limits*: it is
  marked **Content coming soon** and never opens an empty screen.
- **No network needed.** Airplane mode changes nothing in the loop.
- **Team-ready interfaces.** Diagnosis, adaptation and persistence are behind
  interfaces; the app ships with offline mocks that drop-in real services can
  replace without touching the UI.

## If something goes wrong on stage

- Stuck loading: the screens have retry actions; tap **Try again**.
- Wrong screen: use the back button once and re-enter from Home.
- If a device is unavailable, run `flutter run -d chrome`; the whole demo works
  in the browser.
