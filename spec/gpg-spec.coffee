gpg = require '../lib/gpg'
gpg.testMode = true

describe "gpg", ->

  describe "encrypt(text, password, callback)", ->
    it "encrypts hello with world", ->
      gpg.encrypt 'hello', 'world', (err, res) ->
        expect(err).toBe null
        expect(res.startsWith('-----BEGIN PGP MESSAGE-----')).toBe(true)
        expect(res.endsWith('-----END PGP MESSAGE-----\n')).toBe(true)

    it "returns error if no password provided", ->
      gpg.encrypt 'hello', null, (err, res) ->
        expect(res).toBe null
        expect(err).toBe 'No password provided'

      gpg.encrypt 'hello', '', (err, res) ->
        expect(res).toBe null
        expect(err).toBe 'No password provided'

  describe "decrypt(text, password, callback)", ->
    it "returns error if no password provided", ->
      gpg.decrypt 'hello', null, (err, res) ->
        expect(res).toBe null
        expect(err).toBe 'No password provided'

      gpg.decrypt 'hello', '', (err, res) ->
        expect(res).toBe null
        expect(err).toBe 'No password provided'

    it "decrypts hello with world", ->
      gpg.encrypt 'hello', 'world', (err, res) ->
        expect(err).toBe null
        gpg.decrypt res, 'world', (err, res) ->
          expect(err).toBe null
          expect(res).toBe 'hello'
