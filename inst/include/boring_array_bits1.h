#define SET_ARRAY_CHINDS_D1( x, DR1) \
  vector<int> _CHINDID__##x( 1); _CHINDID__##x << #DR1;

#define SET_ARRAY_CHINDS_D2( x, DR1, DR2) \
  vector<int> _CHINDID__##x( 2); _CHINDID__##x << #DR1, #DR2;

#define SET_ARRAY_CHINDS_D3( x, DR1, DR2, DR3) \
  vector<int> _CHINDID__##x( 3); _CHINDID__##x << #DR1, #DR2, #DR3;

#define SET_ARRAY_CHINDS_D4( x, DR1, DR2, DR3, DR4) \
  vector<int> _CHINDID__##x( 4); _CHINDID__##x << #DR1, #DR2, #DR3, #DR4;

#define SET_ARRAY_CHINDS_D5( x, DR1, DR2, DR3, DR4, DR5) \
  vector<int> _CHINDID__##x( 5); _CHINDID__##x << #DR1, #DR2, #DR3, #DR4, #DR5;

#define SET_ARRAY_CHINDS_D6( x, DR1, DR2, DR3, DR4, DR5, DR6) \
  vector<int> _CHINDID__##x( 6); _CHINDID__##x << #DR1, #DR2, #DR3, #DR4, #DR5, #DR6;

#define SET_ARRAY_CHINDS_D7( x, DR1, DR2, DR3, DR4, DR5, DR6, DR7) \
  vector<int> _CHINDID__##x( 7); _CHINDID__##x << #DR1, #DR2, #DR3, #DR4, #DR5, #DR6, #DR7;

