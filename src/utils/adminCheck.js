import { ref as databaseRef, get } from "firebase/database";
import { auth, database, storage } from '../firebase';
export const checkIfAdmin = async (user) => {
  if (!user) return false;
  const adminsRef = databaseRef(database, 'admins');
  const snapshot = await get(adminsRef);
  const admins = snapshot.val();
  return Object.values(admins).includes(user.email);
};
