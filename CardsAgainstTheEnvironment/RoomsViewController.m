//
//  RoomsViewController.m
//  CardsAgainstTheEnvironment
//
//  Created by Dominic Ong on 9/13/14.
//  Copyright (c) 2014 Dominic Ong. All rights reserved.
//

#import "RoomsViewController.h"
#import "RoomCell.h"
#import "CreateGameViewController.h"
#import "RoomViewController.h"
@interface RoomsViewController()
@property (strong, nonatomic) NSMutableArray *roomList;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation RoomsViewController{
    PFObject *room;
    BOOL roomsLoaded;
}


-(void)viewDidLoad{
    _roomList = [[NSMutableArray alloc] init];
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(loadRooms)
             forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:_refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [self loadRooms];
}

-(void)loadRooms{
    roomsLoaded = NO;
    NSLog(@"User: %@", [_user description]);
    [_roomList removeAllObjects];
    PFQuery *roomQuery = [PFQuery queryWithClassName:@"Room"];
    [roomQuery findObjectsInBackgroundWithBlock:^(NSArray *rooms, NSError *error) {
        roomsLoaded = YES;
        for(PFObject *aRoom in rooms){
            NSLog(@"%@", [aRoom objectForKey:@"name"]);
            [_roomList addObject:aRoom];
        }
        [_refreshControl endRefreshing];
        [self.collectionView reloadData];
    }];
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(roomsLoaded){
        return YES;
    }else{
        return NO;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_roomList count];
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, 20, 15, 20);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    room = [_roomList objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ShowRoom" sender:self];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RoomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Room" forIndexPath:indexPath];
    [cell.roomNameLabel setText:[[_roomList objectAtIndex:indexPath.row] objectForKey:@"name"]];
    NSString *turnText;
    if([_user.username isEqualToString:[[_roomList objectAtIndex:indexPath.row] objectForKey:@"currentPlayer"]]){
        [cell.turnLabel setTextColor:[UIColor redColor]];
        turnText = @"Your Turn!";
    }else{
        [cell.turnLabel setTextColor:[UIColor blackColor]];
        turnText = [NSString stringWithFormat:@"%@'s Turn",[[_roomList objectAtIndex:indexPath.row] objectForKey:@"currentPlayer"]];
    }
    [cell.turnLabel setText: turnText];
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"Add"]){
        CreateGameViewController *vc = (CreateGameViewController *)[segue destinationViewController];
        vc.user = _user;
    }else if ([[segue identifier] isEqualToString:@"ShowRoom"]){
        RoomViewController *vc = (RoomViewController *)[segue destinationViewController];
        vc.user = _user;
        vc.room = room;
    }
}

- (IBAction)logout:(id)sender {
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addRoom:(id)sender {
    
    
}
@end
