import jwt from 'jsonwebtoken';

export const verifyToken = (req, res, next) => {
    const token = req.headers['authorization'];

    if (!token) {
        return res.status(403).json({ message: 'Aucun token fourni !' });
    }

    try {
        const decoded = jwt.verify(token.split(' ')[1], process.env.JWT_SECRET);
        req.user = decoded;  // On stocke les infos du token dans `req.user`
        next();
    } catch (error) {
        return res.status(401).json({ message: 'Token invalide !' });
    }
};

export const checkRole = (roles) => {
    return (req, res, next) => {
        if (!roles.includes(req.user.role)) {
            return res.status(403).json({ message: 'Accès refusé : rôle insuffisant.' });
        }
        next();
    };
};
