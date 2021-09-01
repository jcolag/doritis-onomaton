# doritis-onomaton

The Giver of (Useless) Names (in Flutter)

**Doritís Onomáton** ("The Giver of Names") is a throwaway experiment in [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/).  Because an app should probably do *something*, this one generates a series of fake names based on syllable patterns.

Here are some examples of the sorts of names that it generates.

 * Phashnagl
 * Xue
 * Utr
 * Jokosplsplawophascnethr
 * Preh
 * Octraq
 * Emiglow
 * Thisp
 * Ufnu
 * Ejol
 * Omnez
 * Tumnschonyov
 * Ahquich
 * Fiqumeglthrad
 * Shel
 * Eca
 * Fee
 * Easpispri
 * Yanotr
 * Thrikvoki

I created the algorithm (such as it is) for an unrelated project where I wanted nonsense placeholder names not connected to any culture, and these *do* fit that bill.  The generator's rules are basically:

 * Every syllable has a vowel.
 * A syllable might start with a consonant or consonant cluster.
 * A syllable probably ends with a consonant or consonant cluster.
 * The name is more likely to end the longer it gets, but doesn't have a maximum length.

I have some features in mind for the app that I'll discuss here as I add them.

Current versions can save the names to a [**Fýlakas Onomáton**](https://github.com/jcolag/fylakas-onomaton) server, after activation.

