"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.hashPassword = hashPassword;
exports.verifyPassword = verifyPassword;
exports.generateSessionToken = generateSessionToken;
exports.hashToken = hashToken;
exports.addHours = addHours;
const crypto_1 = require("crypto");
const PASSWORD_ITERATIONS = 120000;
const PASSWORD_KEY_LENGTH = 64;
const PASSWORD_DIGEST = "sha512";
function hashPassword(password) {
    const salt = (0, crypto_1.randomBytes)(16).toString("hex");
    const hash = (0, crypto_1.pbkdf2Sync)(password, salt, PASSWORD_ITERATIONS, PASSWORD_KEY_LENGTH, PASSWORD_DIGEST).toString("hex");
    return `${salt}:${hash}`;
}
function verifyPassword(password, passwordHash) {
    const [salt, storedHash] = passwordHash.split(":");
    if (!salt || !storedHash) {
        return false;
    }
    const computedHash = (0, crypto_1.pbkdf2Sync)(password, salt, PASSWORD_ITERATIONS, PASSWORD_KEY_LENGTH, PASSWORD_DIGEST).toString("hex");
    const computedBuffer = Buffer.from(computedHash, "hex");
    const storedBuffer = Buffer.from(storedHash, "hex");
    if (computedBuffer.length !== storedBuffer.length) {
        return false;
    }
    return (0, crypto_1.timingSafeEqual)(computedBuffer, storedBuffer);
}
function generateSessionToken() {
    return (0, crypto_1.randomBytes)(32).toString("hex");
}
function hashToken(token) {
    return (0, crypto_1.createHash)("sha256").update(token).digest("hex");
}
function addHours(date, hours) {
    return new Date(date.getTime() + hours * 60 * 60 * 1000);
}
//# sourceMappingURL=crypto.util.js.map